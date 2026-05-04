import uuid
from datetime import datetime, timedelta

import pytest

from app import app, db
from models import Tecnico, LogVerificacion


@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'

    with app.app_context():
        db.create_all()

    with app.test_client() as test_client:
        yield test_client

    with app.app_context():
        db.session.remove()
        db.drop_all()


def _create_tecnico(estado='activo', exp_delta_days=5):
    token = str(uuid.uuid4())
    tecnico = Tecnico(
        nombre='Juan Perez',
        empresa='Servicios Industriales SA',
        numero_empleado=f'EMP-{token[:8]}',
        foto='/uploads/tecnicos/fotos/juan.png',
        token_qr=token,
        estado=estado,
        fecha_expiracion=datetime.utcnow() + timedelta(days=exp_delta_days),
    )
    db.session.add(tecnico)
    db.session.commit()
    return tecnico


def test_verificacion_token_valido(client):
    with app.app_context():
        tecnico = _create_tecnico(estado='activo', exp_delta_days=3)
        token = tecnico.token_qr

    response = client.get(f'/verificar/{token}')
    assert response.status_code == 200
    assert b'Tecnico verificado' in response.data

    with app.app_context():
        logs = LogVerificacion.query.filter_by(token_consultado=token).all()
        assert any(log.resultado == 'valido' for log in logs)


def test_verificacion_token_invalido(client):
    bad_token = str(uuid.uuid4())
    response = client.get(f'/verificar/{bad_token}')
    assert response.status_code == 404
    assert b'Credencial invalida o expirada' in response.data

    with app.app_context():
        logs = LogVerificacion.query.filter_by(token_consultado=bad_token).all()
        assert any(log.resultado == 'token_invalido' for log in logs)


def test_verificacion_tecnico_expirado(client):
    with app.app_context():
        tecnico = _create_tecnico(estado='activo', exp_delta_days=-1)
        token = tecnico.token_qr

    response = client.get(f'/verificar/{token}')
    assert response.status_code == 200
    assert b'Credencial invalida o expirada' in response.data

    with app.app_context():
        logs = LogVerificacion.query.filter_by(token_consultado=token).all()
        assert any(log.resultado == 'expirado' for log in logs)


def test_verificacion_tecnico_suspendido(client):
    with app.app_context():
        tecnico = _create_tecnico(estado='suspendido', exp_delta_days=5)
        token = tecnico.token_qr

    response = client.get(f'/verificar/{token}')
    assert response.status_code == 200
    assert b'Credencial invalida o expirada' in response.data

    with app.app_context():
        logs = LogVerificacion.query.filter_by(token_consultado=token).all()
        assert any(log.resultado == 'suspendido' for log in logs)
