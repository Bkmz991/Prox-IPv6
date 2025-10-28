#!/usr/bin/env python3
"""
IPv6 Proxy Generator - Setup Script
Автоматическая установка и запуск прокси-сервера
"""

import os
import sys
import subprocess

def check_root():
    """Проверка запуска от root"""
    # Проверка только для Linux/Unix систем
    if hasattr(os, 'geteuid') and os.geteuid() != 0:
        print("❌ Этот скрипт нужно запускать от root!")
        print("   Используйте: sudo python3 setup.py")
        sys.exit(1)

def check_requirements():
    """Проверка необходимых утилит"""
    print("🔍 Проверка системных требований...")
    
    required = ['bash', 'chmod']
    missing = []
    
    for cmd in required:
        if subprocess.run(['which', cmd], capture_output=True).returncode != 0:
            missing.append(cmd)
    
    if missing:
        print(f"❌ Отсутствуют утилиты: {', '.join(missing)}")
        sys.exit(1)
    
    print("✅ Все требования выполнены")

def main():
    """Основная функция"""
    print("=" * 60)
    print("🚀 IPv6 Proxy Generator v2.0")
    print("=" * 60)
    print()
    
    # Проверки
    check_root()
    check_requirements()
    
    # Получаем путь к скрипту
    script_dir = os.path.dirname(os.path.abspath(__file__))
    npprproxy_path = os.path.join(script_dir, 'NPPRPROXY.sh')
    
    # Проверяем наличие скрипта
    if not os.path.exists(npprproxy_path):
        print(f"❌ Файл не найден: {npprproxy_path}")
        sys.exit(1)
    
    print(f"📁 Рабочая директория: {script_dir}")
    print(f"📄 Скрипт: {npprproxy_path}")
    print()
    
    # Даём права на выполнение
    print("🔧 Установка прав на выполнение...")
    os.chmod(npprproxy_path, 0o755)
    print("✅ Права установлены")
    print()
    
    # Запускаем основной скрипт
    print("🚀 Запуск установки прокси...")
    print("=" * 60)
    print()
    
    try:
        subprocess.run(['bash', npprproxy_path], check=True)
    except subprocess.CalledProcessError as e:
        print()
        print("=" * 60)
        print(f"❌ Ошибка при выполнении скрипта: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print()
        print("=" * 60)
        print("⚠️ Установка прервана пользователем")
        sys.exit(1)
    
    print()
    print("=" * 60)
    print("✅ Установка завершена!")
    print("=" * 60)

if __name__ == '__main__':
    main()

