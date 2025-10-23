"""add_second_crew

Revision ID: 8f681827b456
Revises: 0004
Create Date: 2025-10-21 23:16:36.147380

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8f681827b456'
down_revision = '0004'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Добавляем вторую команду
    op.execute("""
        INSERT INTO crews (name, description, max_members, owner_id, created_at, updated_at)
        VALUES ('Команда тестирования', 'Команда для тестирования роботов', 3, 1, NOW(), NOW())
    """)


def downgrade() -> None:
    # Удаляем вторую команду
    op.execute("DELETE FROM crews WHERE name = 'Команда тестирования'")
