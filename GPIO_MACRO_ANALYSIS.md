# GPIO Macro Analysis Report

## Макросы из common/gpio.h (below "finally useful part")

Определены с защитой `#if !defined()`:

1. **GPIO_BSET(name)** - Set pin = 1
2. **GPIO_BCLR(name)** - Clear pin = 0
3. **GPIO_BTGL(name)** - Toggle pin
4. **GPIO_DIR_OUT(name)** - Set as output
5. **GPIO_DIR_INP(name)** - Set as input
6. **GPIO_PULLUP_EN(name)** - Enable pull-up
7. **GPIO_PULLUP_DIS(name)** - Disable pull-up
8. **GPIO_BGET(name)** - Read pin state

## Текущее использование в базовом коде grbl/*.c

### ✅ Файлы с ХОРОШИМ использованием макросов

#### **stepper.c** (grbl/stepper.c)
- ✅ GPIO_BSET/BCLR (строки 229, 231, 271, 273) - STEPPERS_DISABLE
- ✅ GPIO_WR (строки 331, 343, 499, 561-567) - DIRECTION_PORT, STEP_PORT
- ✅ GPIO_OUT (строки 576-578) - DDR инициализация
- ✅ GPIO_SET_OUT (строка 577) - STEPPERS_DISABLE

#### **coolant_control.c** (grbl/coolant_control.c)
- ✅ GPIO_SET_OUT (строки 27, 29) - COOLANT_FLOOD, COOLANT_MIST
- ✅ GPIO_BSET/BCLR (строки 64-112) - Все операции вкл/выкл
- ✅ GPIO_PIN_RD (строки 40, 42, 48, 50) - Чтение состояния

#### **spindle_control.c** (grbl/spindle_control.c)
- ✅ GPIO_SET_OUT (строки 36, 39, 42, 47, 49) - Инициализация
- ✅ GPIO_PIN_RD (строки 72, 86) - Чтение направления
- ⚠️ **bit_istrue/bit_isfalse** (строки 63, 65, 79, 81) - МОЖНО УЛУЧШИТЬ!

#### **limits.c** (grbl/limits.c)
- ✅ GPIO_IN (строка 44) - LIMIT_DDR
- ✅ GPIO_PULLUP_ON/OFF (строки 47, 49) - LIMIT_PORT
- ✅ GPIO_INT_ON/OFF (строки 53, 67) - Interrupt control
- ✅ GPIO_RD (строка 77) - LIMIT_PIN

#### **probe.c** (grbl/probe.c)
- ✅ GPIO_IN (строка 32) - PROBE_DDR
- ✅ GPIO_RD (строка 54) - probe_get_state()

#### **system.c** (grbl/system.c)
- ✅ GPIO_IN (строка 27) - CONTROL_DDR
- ✅ GPIO_RD (строка 43) - CONTROL_PIN

---

## 🔍 Возможности для улучшения

### 1. spindle_control.c - Заменить bit_istrue/bit_isfalse

**Текущий код (строки 63, 65, 79, 81):**
```c
#ifdef INVERT_SPINDLE_ENABLE_PIN
  if (bit_isfalse(SPINDLE_ENABLE_PORT,(1<<SPINDLE_ENABLE_BIT))) { return(SPINDLE_STATE_CW); }
#else
  if (bit_istrue(SPINDLE_ENABLE_PORT,(1<<SPINDLE_ENABLE_BIT))) { return(SPINDLE_STATE_CW); }
#endif
```

**Проблема:**
- Использует старые AVR-специфичные макросы `bit_istrue/bit_isfalse`
- Требует передачу PORT и маски отдельно
- Не портируемо на ARM

**Решение - использовать GPIO_BGET:**
```c
// Нужно добавить определения в cpu_map.h:
#define SPINDLE_ENABLE_PORT  PORTB  // уже есть
#define SPINDLE_ENABLE_BIT   0      // уже есть

// Тогда в spindle_control.c можно написать:
#ifdef INVERT_SPINDLE_ENABLE_PIN
  if (!GPIO_BGET(SPINDLE_ENABLE)) { return(SPINDLE_STATE_CW); }
#else
  if (GPIO_BGET(SPINDLE_ENABLE)) { return(SPINDLE_STATE_CW); }
#endif
```

**Но есть проблема:**
- GPIO_BGET читает INPUT регистр (PINB для AVR)
- bit_istrue читает OUTPUT регистр (PORTB для AVR)
- Это **РАЗНЫЕ** регистры!

**Для output pin-ов нужен другой макрос - GPIO_OUT_GET:**
```c
// В common/gpio.h нужно добавить:
#if !defined(GPIO_OUT_GET)
 #define GPIO_OUT_GET(name)  ( GPIO_OUT_REG(name) & BIT_MSK(name##_BIT) )  // Read OUTPUT register
#endif
```

### 2. Возможные улучшения в других файлах

#### limits.c - все уже оптимально ✅
#### probe.c - все уже оптимально ✅
#### system.c - все уже оптимально ✅
#### coolant_control.c - все уже оптимально ✅

---

## 📊 Статистика использования макросов

| Макрос | Использований | Файлы |
|--------|--------------|-------|
| GPIO_BSET | 10+ | stepper.c, coolant_control.c |
| GPIO_BCLR | 10+ | stepper.c, coolant_control.c |
| GPIO_WR | 15+ | stepper.c |
| GPIO_RD | 5+ | stepper.c, limits.c, probe.c, system.c |
| GPIO_SET_OUT | 8+ | stepper.c, coolant_control.c, spindle_control.c |
| GPIO_IN | 3 | limits.c, probe.c, system.c |
| GPIO_PULLUP_ON/OFF | 2 | limits.c |
| GPIO_INT_ON/OFF | 2 | limits.c |
| GPIO_PIN_RD | 5+ | coolant_control.c, spindle_control.c |

---

## ⚠️ Важные замечания по common/gpio.h

### Определения регистров для AVR

```c
// Из common/gpio.h (строки 45-59):
#if !defined(GPIO_OUT_REG)
 #define GPIO_OUT_REG(name)  name##_PORT   // Output register (PORTB для AVR)
#endif

#if !defined(GPIO_INP_REG)
 #define GPIO_INP_REG(name)  name##_PIN    // Input register (PINB для AVR)
#endif

#if !defined(GPIO_DIR_REG)
 #define GPIO_DIR_REG(name)  name##_DDR    // Direction register (DDRB для AVR)
#endif

#if !defined(GPIO_PU_REG)
 #define GPIO_PU_REG(name)   name##_PORT   // Pull-up = Output register для AVR
#endif
```

### Как это работает на AVR:

Для `STEPPERS_DISABLE` с определениями в cpu_map.h:
```c
#define STEPPERS_DISABLE_PORT  PORTB
#define STEPPERS_DISABLE_BIT   0
```

Макросы раскрываются:
```c
GPIO_BSET(STEPPERS_DISABLE)
→ BIT_SET( GPIO_OUT_REG(STEPPERS_DISABLE), STEPPERS_DISABLE_BIT )
→ BIT_SET( STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_BIT )
→ BIT_SET( PORTB, 0 )
→ { PORTB |= (1<<0); }
```

Это **идентично** оригинальному AVR коду! → **MD5 должен совпадать** ✅

---

## 🎯 Рекомендации

### 1. Немедленные действия (безопасно):
- ✅ **УЖЕ СДЕЛАНО:** Невидимое портирование через `-include common/gpio.h`
- ✅ **УЖЕ СДЕЛАНО:** Guard-ы в hal_gpio.h для предотвращения конфликтов

### 2. Опциональные улучшения:

#### A) Добавить GPIO_OUT_GET в common/gpio.h
Для чтения OUTPUT регистра (нужно для spindle enable pin):
```c
#if !defined(GPIO_OUT_GET)
 #define GPIO_OUT_GET(name)  ( GPIO_OUT_REG(name) & BIT_MSK(name##_BIT) )
#endif
```

#### B) Заменить bit_istrue/bit_isfalse в spindle_control.c
После добавления GPIO_OUT_GET (пункт A).

### 3. Тестирование MD5:
```bash
make clean
make
md5sum grbl.hex  # Ожидается: 79af184e67b27defd27a39309ac53563
```

Или через скрипт:
```bash
python3 grbl/platform/common/chk.py grbl.hex
```

---

## ✨ Выводы

1. **Базовый код уже хорошо портирован** - большинство файлов используют HAL макросы
2. **common/gpio.h имеет высший приоритет** благодаря `-include`
3. **Для AVR макросы раскрываются идентично** → MD5 должен совпадать
4. **Остались мелкие улучшения** в spindle_control.c (bit_istrue/isfalse)
5. **Портирование чистое и невидимое** - никаких изменений в grbl/*.c

**Статус:** Готово к тестированию сборки AVR для проверки MD5! 🎉
