# Quick Start: Optimization Flags Investigation

Краткая инструкция для запуска исследования оптимизационных флагов.

---

## 🚀 Быстрый старт

### 1. Подготовка

```bash
cd /home/user/grbl

# Сделать скрипт исполняемым
chmod +x investigate_flags.sh
chmod +x analyze_float_safety.py
```

### 2. Запуск автоматического исследования

```bash
# ВАЖНО: Скрипт ожидает что Makefile поддерживает переменную EXTRA_CFLAGS
# Если нет, нужно временно модифицировать Makefile

./investigate_flags.sh
```

Скрипт выполнит:
- ✅ 9 сборок с разными комбинациями флагов
- ✅ Генерацию дизассемблера для каждой
- ✅ Сравнение с baseline
- ✅ Извлечение float операций
- ✅ Создание таблицы результатов

**Время выполнения:** ~15-20 минут

---

## 📊 Результаты

После выполнения получите:

### Директории
```
builds/         - ELF файлы для каждой конфигурации
disasm/         - Дизассемблированный код
symbols/        - Таблицы символов
diffs/          - Сравнения с baseline
```

### Файлы
```
optimization_results.txt  - Таблица размеров
diffs/fast-math_vs_baseline.diff  - Полный diff для -ffast-math
diffs/fast-math_changed_functions.txt  - Список изменённых функций
diffs/fast-math_float_changes.diff  - Изменения float операций
```

---

## 🔍 Анализ -ffast-math

### Автоматический анализ безопасности

```bash
python3 analyze_float_safety.py \
    disasm/main_baseline.asm \
    disasm/main_fast-math.asm \
    fast_math_safety_report.md
```

Создаст подробный отчёт с:
- Список критических функций и их изменения
- Оценка рисков для каждой функции
- Рекомендации по использованию
- Чеклист для тестирования

---

## 📖 Ручной анализ

### Посмотреть изменения в критической функции

```bash
# Найти функцию в дизассемблере
grep -A 50 "<mc_arc>:" disasm/main_baseline.asm > /tmp/mc_arc_baseline.txt
grep -A 50 "<mc_arc>:" disasm/main_fast-math.asm > /tmp/mc_arc_fastmath.txt

# Сравнить
diff -u /tmp/mc_arc_baseline.txt /tmp/mc_arc_fastmath.txt
```

### Найти где используется reciprocal division

```bash
# Опасная оптимизация: a/b → a*(1/b)
grep "__divsf3x" disasm/main_fast-math.asm
```

### Проверить изменения в Bezier evaluation

```bash
# Критично для спайнов - порядок операций важен!
grep -A 30 "<eval_bezier>:" disasm/main_baseline.asm > /tmp/bezier_base.txt
grep -A 30 "<eval_bezier>:" disasm/main_fast-math.asm > /tmp/bezier_fast.txt
diff -u /tmp/bezier_base.txt /tmp/bezier_fast.txt
```

---

## ⚠️ На что обращать внимание

### Критичные изменения (-ffast-math)

1. **Переупорядочивание float операций**
   ```asm
   ; Baseline:
   fadd r24, r22    ; a + b
   fadd r24, r20    ; + c

   ; Fast-math (ОПАСНО!):
   fadd r22, r20    ; b + c (может потерять точность)
   fadd r24, r22    ; a + (b+c)
   ```

2. **Reciprocal multiplication**
   ```asm
   ; Baseline:
   call __divsf3    ; a / b

   ; Fast-math (менее точно):
   call __divsf3x   ; a * (1/b)
   ```

3. **Sqrt approximation**
   ```asm
   ; Baseline:
   call __sqrt

   ; Fast-math:
   call __rsqrt     ; 1/sqrt(x) - может быть менее точным
   ```

### Функции требующие особого внимания

**Категория: Motion Planning**
- `plan_buffer_line` - расчёт траектории
- `planner_recalculate` - пересчёт скоростей

**Категория: Arc Interpolation**
- `mc_arc` - G2/G3 дуги (использует sin/cos/sqrt)

**Категория: Splines**
- `eval_bezier` - полиномиальная интерполяция (ОЧЕНЬ чувствительна к порядку операций!)
- `mc_cubic_b_spline` - адаптивное разбиение

---

## 📈 Интерпретация результатов

### Таблица размеров

```
Configuration        Flash (B)  Savings    % Saved
--------------------  ---------- ---------- ----------
baseline              30066      0          0.00%
lto                   29800      266        0.88%
fast-math             29500      566        1.88%
...
```

**Вопросы:**
1. Сколько байт даёт каждый флаг?
2. Какова цена (risk/savings ratio)?
3. Можно ли скомбинировать безопасные флаги?

### Оценка рисков

| Risk Level | Значение | Действие |
|-----------|----------|----------|
| SAFE | Нет изменений | ✅ Можно использовать |
| LOW | Минорные изменения | ✅ Вероятно безопасно |
| MEDIUM | Требует проверки | ⚠️ Нужно тестирование |
| HIGH | Значительные изменения | 🔴 Осторожно! |
| CRITICAL | Опасно | 🛑 Не рекомендуется |

---

## 🧪 План тестирования

После применения флагов **обязательно** протестировать:

### 1. Базовые движения
```gcode
G0 X10 Y10       ; Быстрое перемещение
G1 X20 Y20 F100  ; Линейное с подачей
```

### 2. Дуги
```gcode
G17              ; XY плоскость
G2 X10 Y0 I5 J0  ; Полукруг по часовой
G3 X0 Y10 I-5 J0 ; Полукруг против часовой
```

### 3. Спайны (если включены)
```gcode
G5 X10 Y10 I2 J2 P2 Q2  ; Кубический сплайн
```

### 4. Точность позиционирования
```gcode
; Выполнить 1000 раз и проверить конечную позицию
G0 X10 Y10
G0 X0 Y0
; Должны вернуться точно в (0,0)
```

### 5. Острые углы
```gcode
; Проверка ускорения/торможения
G1 X10 F1000
G1 Y10
G1 X0
G1 Y0
```

---

## 📝 Примечания

### Если Makefile не поддерживает EXTRA_CFLAGS

Временно отредактируйте Makefile:

```makefile
# Было:
COMPILE = avr-gcc -Wall -Os -DF_CPU=16000000 -mmcu=atmega328p

# Стало:
COMPILE = avr-gcc -Wall -Os -DF_CPU=16000000 -mmcu=atmega328p $(EXTRA_CFLAGS)
```

### Для GCC 15.2

Вы упомянули что используете avr-gcc 15.2. Убедитесь что PATH указывает на правильную версию:

```bash
which avr-gcc
avr-gcc --version
```

---

## 🎯 Конечная цель

Получить таблицу:

| Flag | Savings | Risk | Recommendation |
|------|---------|------|----------------|
| -flto | XXX B | SAFE | ✅ Use |
| -Wl,--relax | XXX B | SAFE | ✅ Use |
| -mcall-prologues | XXX B | SAFE | ✅ Use |
| -fno-inline-small-functions | XXX B | LOW | ✅ Use |
| -fno-split-wide-types | XXX B | SAFE | ✅ Use |
| -fno-tree-scev-cprop | XXX B | LOW | ⚠️ Test |
| **-ffast-math** | **XXX B** | **HIGH?** | **⚠️ ANALYZE** |

И решить: **использовать -ffast-math или нет?**

---

## 📞 Следующие шаги

1. ✅ Запустить `./investigate_flags.sh`
2. ✅ Запустить `python3 analyze_float_safety.py`
3. 📖 Изучить `fast_math_safety_report.md`
4. 🔍 Проверить критические функции вручную
5. 🧪 Провести тестирование на реальном железе
6. ✅ Принять решение по каждому флагу

---

**Удачи в исследовании!** 🚀
