# Quality Gates — Единая система проверки качества

Автоматические проверки на ключевых этапах. Claude ревьюит МОЛЧА, показывает пользователю только финальный результат.

---

## Gate 1: After Plan (размер M и L)

**Триггер:** План/архитектура создана

**Субагенты:** architect, security-reviewer

**Что проверяют:**
- Архитектура адекватна масштабу задачи (не overengineering)
- Нет security-дыр в дизайне
- Оценка времени реалистична

**Процесс:** Проверить → исправить молча → показать пользователю финал.

---

## Gate 2: After Code (>10 строк)

**Триггер:** Написан код >10 строк

**Субагенты:** code-reviewer + anti-mirage check (из rules/anti-mirage.md)
Если security-sensitive код (авторизация, платежи, ввод данных): + security-reviewer

**Что проверяют:**

code-reviewer:
- DRY, KISS, YAGNI
- Функции <50 строк, файлы <500 строк
- Нет magic numbers, нет хардкода
- Docstrings на русском

anti-mirage check:
- Все импорты ссылаются на существующие файлы
- Все вызываемые функции существуют
- Все env vars описаны в .env.example
- Все зависимости в package.json / requirements.txt

security-reviewer (если нужен):
- Input validation
- SQL injection, XSS
- Нет хардкоженных секретов

**Процесс:**
1. Написать код
2. Запустить проверки МОЛЧА
3. Исправить всё найденное
4. Повторить если были critical
5. Показать пользователю ТОЛЬКО финальный код
6. Записать ключевые findings в ai-notes текущего блока

---

## Gate 3: Before Deploy (размер M и L)

**Триггер:** Готовим к деплою

**Субагенты:** security-reviewer, architect

**Чеклист:**
- [ ] Все env vars настроены на сервере
- [ ] Секреты не в коде и не в git
- [ ] Порты не конфликтуют с другими сервисами
- [ ] Health check endpoint есть и работает
- [ ] Docker/systemd конфиг корректный
- [ ] Nginx конфиг корректный (если web)
- [ ] SSL настроен (если web)
- [ ] Логирование настроено

---

## Severity (уровни серьёзности)

Critical → ОБЯЗАТЕЛЬНО исправить. Re-verify после исправления.
Major → Исправить. Не блокирует, но нужно.
Minor → Исправить если быстро (<2 мин). Иначе записать в ai-notes как техдолг.

---

## Skip

Пользователь может пропустить: "пропусти проверку" / "skip review" / "без ревью"

Claude предупредит: "Quality Gate пропущен. Код может содержать проблемы."

Но НИКОГДА не пропускать anti-mirage check — это слишком дёшево и слишком ценно.

---

## Формат записи в ai-notes

После Gate 2, если были findings — добавить в docs/ai-notes/block-N.md:

```markdown
## Quality Gate findings

### Исправлено молча:
- SQL injection в handlers/payment.py → параметризованные запросы
- Missing input validation в /start → добавлен валидатор

### Техдолг (minor, отложено):
- Функция process_order() слишком длинная (48 строк) → разбить позже
```

---

## Адаптивность по размеру

| Gate | S (Quick Fix) | M (Feature) | L (Epic) |
|------|--------------|-------------|----------|
| Gate 1 (Plan) | skip | да | да |
| Gate 2 (Code) | anti-mirage only | full | full |
| Gate 3 (Deploy) | skip | да | да |
