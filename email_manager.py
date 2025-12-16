import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
import os
from dotenv import load_dotenv
import logging

logger = logging.getLogger(__name__)
load_dotenv()

class EmailManager:
    """Gestor de envío de correos para notificaciones de tickets"""
    
    def __init__(self):
        self.smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.getenv('SMTP_PORT', '587'))
        self.sender_email = os.getenv('SENDER_EMAIL', 'noreply@catalogo.com')
        self.sender_password = os.getenv('SENDER_PASSWORD', '')
        self.use_tls = os.getenv('SMTP_USE_TLS', 'True').lower() == 'true'
        
    def enviar_notificacion_nuevo_ticket(self, ticket_data, ingeniero_email):
        """Notifica al ingeniero sobre un nuevo ticket asignado"""
        asunto = f"Nuevo Ticket Asignado: {ticket_data['numero_ticket']} - {ticket_data['titulo']}"
        
        cuerpo_html = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <h2 style="color: #0066cc;">Nuevo Ticket Asignado</h2>
                <hr>
                <p><strong>Número de Ticket:</strong> {ticket_data['numero_ticket']}</p>
                <p><strong>Título:</strong> {ticket_data['titulo']}</p>
                <p><strong>Usuario:</strong> {ticket_data['usuario_nombre']} ({ticket_data['usuario_correo']})</p>
                <p><strong>Prioridad:</strong> <span style="color: {self._color_prioridad(ticket_data['prioridad'])}; font-weight: bold;">{ticket_data['prioridad'].upper()}</span></p>
                <p><strong>Categoría:</strong> {ticket_data['categoria']}</p>
                <hr>
                <h3>Descripción:</h3>
                <p>{ticket_data['descripcion']}</p>
                <hr>
                <p style="color: #666; font-size: 12px;">Fecha: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
            </body>
        </html>
        """
        
        return self._enviar_email(ingeniero_email, asunto, cuerpo_html)
    
    def enviar_notificacion_usuario(self, ticket_data, usuario_email):
        """Notifica al usuario que su ticket fue recibido"""
        asunto = f"Ticket Recibido: {ticket_data['numero_ticket']}"
        
        cuerpo_html = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <h2 style="color: #0066cc;">Tu Ticket Ha Sido Recibido</h2>
                <hr>
                <p>Hola {ticket_data['usuario_nombre']},</p>
                <p>Tu reporte de incidencia ha sido registrado correctamente.</p>
                <p><strong>Número de Ticket:</strong> {ticket_data['numero_ticket']}</p>
                <p><strong>Título:</strong> {ticket_data['titulo']}</p>
                <p><strong>Estado:</strong> {ticket_data['estado'].replace('_', ' ').upper()}</p>
                <p>Nuestro equipo de sistemas lo atenderá pronto. Puedes seguir el estado de tu ticket en el portal.</p>
                <hr>
                <p style="color: #666; font-size: 12px;">Fecha: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
            </body>
        </html>
        """
        
        return self._enviar_email(usuario_email, asunto, cuerpo_html)
    
    def enviar_notificacion_cambio_estado(self, ticket_data, usuario_email, nuevo_estado):
        """Notifica cambio de estado del ticket"""
        asunto = f"Actualización de Ticket: {ticket_data['numero_ticket']} - {nuevo_estado.replace('_', ' ').upper()}"
        
        cuerpo_html = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <h2 style="color: #0066cc;">Tu Ticket Ha Sido Actualizado</h2>
                <hr>
                <p>Hola {ticket_data['usuario_nombre']},</p>
                <p>Tu ticket ha cambiado de estado:</p>
                <p><strong>Número de Ticket:</strong> {ticket_data['numero_ticket']}</p>
                <p><strong>Nuevo Estado:</strong> <span style="color: {self._color_estado(nuevo_estado)}; font-weight: bold;">{nuevo_estado.replace('_', ' ').upper()}</span></p>
                <hr>
                <p style="color: #666; font-size: 12px;">Fecha: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
            </body>
        </html>
        """
        
        return self._enviar_email(usuario_email, asunto, cuerpo_html)
    
    def _color_prioridad(self, prioridad):
        """Retorna color según prioridad"""
        colores = {
            'baja': '#28a745',
            'media': '#ffc107',
            'alta': '#ff6b6b',
            'critica': '#dc3545'
        }
        return colores.get(prioridad.lower(), '#666')
    
    def _color_estado(self, estado):
        """Retorna color según estado"""
        colores = {
            'abierto': '#007bff',
            'en_progreso': '#ffc107',
            'en_espera': '#6c757d',
            'cerrado': '#28a745'
        }
        return colores.get(estado.lower(), '#666')
    
    def _enviar_email(self, destinatario, asunto, cuerpo_html):
        """Envía email con manejo de errores"""
        try:
            mensaje = MIMEMultipart('alternative')
            mensaje['Subject'] = asunto
            mensaje['From'] = self.sender_email
            mensaje['To'] = destinatario
            
            parte_html = MIMEText(cuerpo_html, 'html')
            mensaje.attach(parte_html)
            
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                if self.use_tls:
                    server.starttls()
                if self.sender_password:
                    server.login(self.sender_email, self.sender_password)
                server.send_message(mensaje)
            
            logger.info(f"✓ Email enviado a {destinatario}")
            return True
        except Exception as e:
            logger.error(f"✗ Error al enviar email a {destinatario}: {e}")
            return False
