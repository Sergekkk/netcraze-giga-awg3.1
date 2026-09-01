# AmneziaWG v3 для Keenetic Giga (KN-1012 / MT7981)

Полнофункциональная интеграция протокола **AmneziaWG версии 3 (AWG v3)** с нативной поддержкой ядра и операционной системы **KeeneticOS (NDMS)** через подсистему **Entware**.

Данный репозиторий позволяет:
1. **С нуля собрать** модуль ядра `amneziawg.ko` и CLI-утилиту `awg` для процессоров **MediaTek MT7981 / Filogic 820** (ARM64 / Cortex-A53) и ядра Linux **4.9.x**.
2. **Быстро развернуть** готовую сборку на роутере с автоматической регистрацией туннелей как системных сетевых интерфейсов Keenetic.
3. **Управлять маршрутизацией** через веб-интерфейс Keenetic (Политики подключений, Multi-WAN, приоритеты, DNS).

---

## 📋 Поддерживаемое оборудование и требования

* **Роутер:** Keenetic Giga (KN-1012 / NC-1012)
* **Чипсет:** MediaTek MT7981B (Filogic 820), 2 ядра ARM Cortex-A53 (ARMv8 / aarch64)
* **Версия ОС:** KeeneticOS 5.01.C.4.0-1 и новее (ядро `4.9.337-ndm-5`)
* **Окружение:** Накопитель USB с установленным Entware (Инструкция по установке Entware на этот роутер: [https://support.netcraze.ru/giga/nc-1012/ru/20980.html](https://support.netcraze.ru/giga/nc-1012/ru/20980.html))
* **Протокол:** AmneziaWG 3.1.x (полная поддержка параметров обфускации и протокола v3: `Jc`, `Jmin`, `Jmax`, `S1`, `S2`, `S3`, `S4`, `H1`–`H4`, `HeaderProtectionKey`, `ContentPaddingAddition`, `RandomTrailers`, `DisableCookies`, `RekeyAfterTime`, `RekeyTimeout`, `RejectAfterTime`, `KeepaliveTimeout`, `MaxHandshakeAttempts`)

---

## 📁 Структура проекта

```
.
├── ARCHITECTURE.md            # Архитектура решения и описание жизненного цикла
├── build/                     # Сборка из исходников (Reproducible Build)
│   ├── Dockerfile             # Среда для сборки в контейнере
│   ├── build.sh               # Главный скрипт автоматической сборки
│   ├── scripts/               # Пошаговые этапы сборки:
│   │   ├── 01_prepare_sdk.sh  # Клонирование и распаковка Keenetic SDK 5.00
│   │   ├── 02_build_kernel.sh # Сборка ядра и генерация Module.symvers
│   │   ├── 03_build_module.sh # Сборка amneziawg.ko с патчами
│   │   └── 04_build_tools.sh  # Кросс-компиляция утилиты awg
│   └── patches/               # Патчи совместимости с ядром 4.9
│       └── 001-amneziawg-linux49-compat.patch
├── prebuilt/                  # Каталог для готовых скомпилированных бинарников
│   └── kn-1012/               # Бинарники для Keenetic Giga KN-1012
│       ├── amneziawg.ko       # Модуль ядра
│       └── awg                # CLI-утилита
└── router/                    # Файлы и скрипты для установки на роутер
    ├── install.sh             # Автоматический скрипт установки
    ├── uninstall.sh           # Скрипт удаления
    ├── opt/
    │   ├── bin/
    │   │   └── awg3-split-config # Парсер .conf -> awg.conf + ndms.sh
    │   └── etc/
    │       ├── init.d/
    │       │   └── S99awg3       # Сервисный SysV init скрипт
    │       └── awg3/
    │           └── conf/         # Папка для конфигов (и подпапка parsed/)
    │               └── awg3_example.conf # Пример конфига с параметрами AWG3
```

---

## 🚀 Быстрый старт (Установка готовой сборки)

Если вы не хотите собирать компоненты самостоятельно, используйте уже готовые скомпилированные файлы из каталога `prebuilt/kn-1012/`:

### 1. Подключение к роутеру по SSH
Зайдите в консоль Entware роутера по SSH (порт зависит от вашей настройки, например 222 или стандартный 22):
```bash
ssh root@<IP-адрес-роутера> -p <порт-SSH>
```

### 2. Загрузка и запуск установщика
Скопируйте содержимое папки `router/` на роутер (например, в `/opt/tmp/awg-install`) и запустите:
```bash
cd /opt/tmp/awg-install
chmod +x install.sh
./install.sh
```

### 3. Добавление конфигураций
Файлы конфигурации можно как создать вручную, так и импортировать (положив готовые файлы `.conf` в папку `/opt/etc/awg3/conf/`). Можно положить сразу несколько файлов — сервис автоматически поднимет все найденные конфигурации.

Пример конфигурации AmneziaWG v3 (`/opt/etc/awg3/conf/my_vpn.conf`):
```ini
[Interface]
MTU = 1300
Address = 10.8.1.5/32
DNS = 1.1.1.1, 1.0.0.1
PrivateKey = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=

# Параметры AmneziaWG v3
Jc = 4
Jmin = 10
Jmax = 70
S1 = 15
S2 = 25
S3 = 24
S4 = 12
H1 = 1
H2 = 2
H3 = 3
H4 = 4
HeaderProtectionKey = <key>
ContentPaddingAddition = 10-100
RekeyAfterTime = 100-120
RekeyTimeout = 3-7
RejectAfterTime = 150-180
KeepaliveTimeout = 5-15
MaxHandshakeAttempts = 15-20
RandomTrailers = on
DisableCookies = on

[Peer]
PublicKey = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=
PresharedKey = ccccccccccccccccccccccccccccccccccccccccccc=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = vpn.example.com:51820
PersistentKeepalive = 25-35
```

> **Важно:** В веб-интерфейсе роутера новые AWG-интерфейсы будут отображаться по названию файла конфигурации (без расширения `.conf`). Например, для файла `my_vpn.conf` интерфейс будет называться `my_vpn`.

### 4. Запуск службы
```bash
/opt/etc/init.d/S99awg3 start
```

### 5. Проверка статуса
```bash
# Статус службы и список поднятых туннелей
/opt/etc/init.d/S99awg3 status

# Прямой вывод данных об активности пиров и трафике
/opt/bin/awg show

# Проверка логов ядра (dmesg)
dmesg | grep -Ei 'amnezia|opkgtun'
```

---

## 🌐 Настройка маршрутизации в веб-интерфейсе Keenetic

После запуска службы туннели регистрируются в KeeneticOS и становятся доступны для политик маршрутизации:

1. Откройте веб-интерфейс роутера в браузере (по локальному адресу, например `192.168.1.1`, `192.168.x.x` или `my.keenetic.net`).
2. Перейдите в раздел **Сетевые правила** -> **Маршрутизация** (или **Приоритеты подключений**).
3. Создайте новую политику маршрутизации (или отредактируйте Основную).
4. В списке подключений найдите и отметьте ваш туннель:
   > **Обратите внимание:** В веб-интерфейсе туннель отображается **строго под человекочитаемым именем файла конфигурации** (например, `my_vpn`). Системные технические имена интерфейсов (`OpkgTun0...N`) скрыты для удобства.
5. Привяжите к этой политике нужные устройства домашней сети, отдельные доменные имена или IP-адреса.

---

## 🛠 Сборка компонентов с нуля из исходников

### Вариант А: Сборка в Docker (Рекомендуется)
*Подходит для любой ОС (Windows, macOS, Linux, старые серверы), где установлен Docker. Все сборочные зависимости и свежий компилятор изолированы внутри контейнера Ubuntu 24.04 и не засоряют вашу хост-систему.*

```bash
cd build
docker build -t keenetic-awg-builder .
docker run --rm -v $(pwd)/out:/home/builder/out keenetic-awg-builder
```
После завершения скомпилированные файлы `amneziawg.ko` и `awg` появятся в папке `build/out/`.

### Вариант Б: Прямая сборка на хосте (Ubuntu 22.04+ / Debian 12+)
*Подходит для сборки напрямую в системе без Docker. Требует современный дистрибутив с версией `glibc ≥ 2.34` (так как кросс-компилятор Keenetic SDK требует актуальный glibc).*

1. Установите зависимости:
   ```bash
   sudo apt update && sudo apt install -y build-essential git libncurses5-dev \
       zlib1g-dev gawk flex bison pkg-config unzip rsync file python3 curl bc
   ```
2. Запустите мастер-скрипт сборки:
   ```bash
   cd build
   ./build.sh
   ```

---

## 📦 Сборочные артефакты и воспроизводимость

Для сохранения полной воспроизводимости сборки в репозитории используются:

1. **Конфигурация ядра:**
   * Автоматическая генерация конфигурации Linux 4.9 для MT7981 / KN-1012 (`.config`) средствами Keenetic SDK (`./configure.sh -pmanual KN-1012`).
   * Таблица символов `Module.symvers`, формируемая при компиляции ядра SDK (`make target/linux/compile`).
2. **Патч совместимости модуля ядра (`build/patches/001-amneziawg-linux49-compat.patch`):**
   * **Адаптация BLAKE2s:** Устраняет конфликт типов между upstream AmneziaWG (ориентированным на ядро 6.19+) и ядром Linux 4.9; транслирует вызовы `awg_blake2s(...)` на порядок аргументов ядра и связывает `struct blake2s_ctx` со структурой `struct blake2s_state` в `noise.c` и `cookie.c`.
   * **Адаптер ChaCha20:** Реализует поблочное шифрование `__compat_chacha20_crypt()` и инициализацию `crypto_chacha_init()` через системные функции ядра MT7981 (`chacha_block`, `crypto_xor`).
   * **Сетевой стек и ICMP:** Автоматически определяет наличие бэкпорта `skb_queue_empty_lockless` в `skbuff.h` через директиву `COMPAT_HAVE_SKB_QUEUE_EMPTY_LOCKLESS` в `Kbuild.include`, а также добавляет корректную обработку ядра `4.9.337` в блоках ICMP/NAT.
   * **Криптоподсистема:** Прямое подключение `crypto/zinc.h` в `main.c`.
3. **Кросс-тулчейн:**
   * Префикс кросс-тулчейна: `aarch64-ndms-linux-musl-` (компилятор `aarch64-ndms-linux-musl-gcc`) из состава Keenetic SDK 5.00.
