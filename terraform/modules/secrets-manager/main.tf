resource "aws_secretsmanager_secret" "sm" {
  name                    = var.secret_name
  recovery_window_in_days = 0
}


resource "aws_secretsmanager_secret_version" "sm_version" {
  secret_id = aws_secretsmanager_secret.sm.id
  secret_string = jsonencode({

    DATABASE_URL          = "postgresql+asyncpg://${var.database_user}:${var.database_password}@${var.database_endpoint}/${var.database_name}"
    REDIS_URL             = "redis://:${var.redis_password}@${var.redis_endpoint}:6379/0"
    CELERY_BROKER_URL     = "redis://:${var.redis_password}@${var.redis_endpoint}:6379/1"
    CELERY_RESULT_BACKEND = "redis://:${var.redis_password}@${var.redis_endpoint}:6379/2"

    JWT_SECRET_KEY      = var.env_var_jwt_secret_key
    MAIL_USERNAME       = var.env_var_mail_username
    MAIL_PASSWORD       = var.env_var_mail_password
    RAZORPAY_KEY_ID     = var.env_var_rzp_key_id
    RAZORPAY_KEY_SECRET = var.env_var_rzp_key_secret
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
