import asyncio


async def create_connection(host, port, index):
    try:
        # Пытаемся установить соединение
        reader, writer = await asyncio.open_connection(host, port)

        # Выводим статус каждые 500 соединений для наглядности
        if index % 500 == 0:
            print(f"Статус: {index} соединений удерживается (ESTABLISHED)")

        # Удерживаем сокет открытым
        while True:
            await asyncio.sleep(3600)

    except Exception as e:
        # Если не получается подключиться, выводим ошибку
        print(f"Ошибка на соединении {index}: {e}")


async def main():
    # Настройки сервера
    server_ip = '3.65.8.238'  # Замените на реальный IP вашего EC2
    server_port = 9001

    target_connections = 25000

    print(f"Запуск теста: цель {target_connections} соединений...")

    tasks = []
    for i in range(1, target_connections + 1):
        tasks.append(create_connection(server_ip, server_port, i))

        # Небольшая пауза, чтобы не перегрузить сетевой стек сразу
        if i % 100 == 0:
            await asyncio.sleep(0.1)

    # Запускаем все задачи одновременно
    await asyncio.gather(*tasks)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nТест остановлен пользователем")
