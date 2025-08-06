# 🍕 SR Pizza - API de Pedidos de Pizza

Una API REST desarrollada con Ruby on Rails para gestionar pedidos de pizza con procesamiento asíncrono usando Sidekiq.

## 📋 Características

- **API REST** para crear, listar y gestionar pedidos de pizza
- **Sistema de ganadores** para seleccionar clientes ganadores de pedidos de pizza
- **Procesamiento asíncrono** de pedidos con Sidekiq
- **Validaciones robustas** con enums para tipos de pizza y tamaños
- **Manejo de errores** completo y logging detallado
- **Base de datos SQLite** para desarrollo rápido

## 🛠️ Requisitos del Sistema

- **Ruby:** 3.2.0 o superior
- **Rails:** 7.2.0 o superior
- **Redis:** Para Sidekiq (jobs en segundo plano)
- **SQLite3:** Base de datos incluida

## 🚀 Instalación y Configuración

### 1. Clonar y preparar el proyecto
```bash
cd {ruta}/sr_pizza
bundle install
```

### 2. Configurar variables de entorno
```bash
# Crear archivo .env basado en el ejemplo
cp .env.example .env
# Editar .env con tus configuraciones específicas
nano .env
```

### 3. Configurar la base de datos
```bash
# Ejecutar migraciones
rails db:migrate

# (Opcional) Cargar datos de prueba
rails db:seed
```

## 🏃‍♂️ Ejecutar la Aplicación

### Opción 1: Ejecución Manual (3 terminales separadas)

**Terminal 1 - Servidor Rails:**
```bash
cd {ruta}/sr_pizza
rails server
```

**Terminal 2 - Sidekiq (Jobs asíncronos):**
```bash
cd {ruta}/sr_pizza
bundle exec sidekiq
```

**Terminal 3 - Pruebas/Comandos:**
```bash
# Usar para ejecutar comandos curl o pruebas
```

## 🧪 Probar la API

### 1. Verificar que el servidor esté corriendo
```bash
curl http://localhost:3000/pizza_orders
# Respuesta esperada: lista de pedidos existentes
```

### 2. Crear un nuevo pedido
```bash
curl --location 'http://localhost:3000/pizza_orders' \
--header 'Content-Type: application/json' \
--data '{
  "customer_name": "Segundo España",
  "pizza_type": "pepperoni",
  "size": "medium"
}'
```

**Respuesta esperada:**
```json
{
  "status": "success"
}
```

### 3. Listar todos los pedidos
```bash
curl http://localhost:3000/pizza_orders
```

### 4. Obtener un pedido específico
```bash
curl http://localhost:3000/pizza_orders/1
```

### 5. ✨ **NUEVO**: Seleccionar un ganador
```bash
curl --location --request POST 'http://localhost:3000/winner_selection' \
--header 'Content-Type: application/json'
```

**Respuesta esperada:**
```json
{
  "status": "success",
  "winner": {
    "id": 3,
    "customer_name": "María Fernández",
    "pizza_type": "vegetarian",
    "size": "small",
    "order_date": "2025-06-18T23:40:28.601Z"
  }
}
```

**Respuesta cuando no hay pedidos:**
```json
{
  "status": "failed",
  "errors": ["No hay pedidos disponibles para seleccionar un ganador"]
}
```

## 📊 Tipos de Pizza y Tamaños Disponibles

### Tipos de Pizza:
- `margherita` - Pizza Margherita clásica
- `pepperoni` - Pizza con pepperoni
- `vegetarian` - Pizza vegetariana

### Tamaños:
- `small` - Pequeña
- `medium` - Mediana  
- `large` - Grande

## 🔧 Comandos Útiles para Desarrollo

### Consola de Rails
```bash
rails console
# Dentro de la consola:
# PizzaOrder.all
# PizzaOrder.create(customer_name: "Test", pizza_type: "margherita", size: "large")
```

### Logs en tiempo real
```bash
# Logs de Rails
tail -f log/development.log

# Logs de Sidekiq
# Ver en la terminal donde corre sidekiq
```

### Reiniciar servicios
```bash
# Reiniciar Rails (Ctrl+C y volver a ejecutar rails s)
# Reiniciar Sidekiq (Ctrl+C y volver a ejecutar bundle exec sidekiq)
# Limpiar cache
rails tmp:clear
```

## 🐛 Solución de Problemas Comunes

### Error: Redis connection refused
```bash
# Instalar Redis (Ubuntu/Debian)
sudo apt-get install redis-server
sudo systemctl start redis-server

# Verificar estado
sudo systemctl status redis-server
```

### Error: Bundle install falla
```bash
# Actualizar bundler
gem update bundler
bundle install
```

### Error: Base de datos bloqueada
```bash
# Resetear base de datos
rails db:drop db:create db:migrate
```

### Error en Sidekiq: NoMethodError
```bash
# Verificar que ProcessOrderJob herede de ApplicationJob
# Reiniciar Sidekiq después de cambios en jobs
```

## 📝 Ejemplos de Pruebas Adicionales

### Crear múltiples pedidos
```bash
# Pedido 1
curl -X POST http://localhost:3000/pizza_orders \
-H "Content-Type: application/json" \
-d '{"customer_name": "Ana García", "pizza_type": "margherita", "size": "small"}'

# Pedido 2
curl -X POST http://localhost:3000/pizza_orders \
-H "Content-Type: application/json" \
-d '{"customer_name": "Carlos López", "pizza_type": "vegetarian", "size": "large"}'
```

### Probar validaciones (debería fallar)
```bash
# Sin nombre de cliente
curl -X POST http://localhost:3000/pizza_orders \
-H "Content-Type: application/json" \
-d '{"pizza_type": "pepperoni", "size": "medium"}'

# Tipo de pizza inválido
curl -X POST http://localhost:3000/pizza_orders \
-H "Content-Type: application/json" \
-d '{"customer_name": "Test", "pizza_type": "hawaiana", "size": "medium"}'
```

## 🚀 Deployment en Producción

1. Configurar variables de entorno de producción
2. Usar base de datos PostgreSQL
3. Configurar Redis en servidor dedicado
4. Usar servidor web como Nginx + Puma
5. Configurar monitoreo con herramientas como New Relic

---