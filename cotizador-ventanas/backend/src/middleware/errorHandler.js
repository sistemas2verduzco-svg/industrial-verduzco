export function notFoundHandler(req, res) {
  res.status(404).json({
    message: 'Endpoint no encontrado',
    path: req.originalUrl,
  });
}

export function errorHandler(error, req, res, next) {
  const status = error.status || 500;
  const response = {
    message: error.message || 'Error interno del servidor',
  };

  if (process.env.NODE_ENV !== 'production' && error.details) {
    response.details = error.details;
  }

  res.status(status).json(response);
}
