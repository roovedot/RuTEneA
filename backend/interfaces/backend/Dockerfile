FROM python:3.11

# Establecer el directorio de trabajo en /app
WORKDIR /app

# Copiar el archivo requirements.txt
COPY requirements.txt .

# Instalar las dependencias
RUN pip install --no-cache-dir -r requirements.txt && sleep 2

# Copiar todo el código al contenedor
COPY . .

# Ejecutar las migraciones de la base de datos (esto ya debería existir tras inicializar el directorio)
RUN flask db init
RUN flask db migrate
RUN flask db upgrade

# Comando para iniciar la aplicación
CMD ["python", "app.py"]
