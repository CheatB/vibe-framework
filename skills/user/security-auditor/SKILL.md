---
name: security-auditor
description: |
  Аудит безопасности кода и инфраструктуры: секреты, инъекции, уязвимости.

  Использовать когда: "проверь безопасность", "security audit", "найди уязвимости",
  "проверь на секреты", "безопасность кода", "перед деплоем"
---

# Security Auditor

## Быстрый аудит (при каждом коммите)

Автоматически проверяется через hooks (security-scan.sh, protect-secrets.sh):

1. **Секреты в коде** — API ключи, токены, пароли, приватные ключи
2. **SQL инъекции** — конкатенация строк в запросах
3. **XSS** — innerHTML с пользовательским вводом
4. **Хардкод конфигов** — URL, порты, пути прописаны прямо в коде

## Полный аудит (перед деплоем)

### 1. Секреты и ключи

```bash
# Паттерны для поиска
grep -rn 'API_KEY=\|SECRET=\|PASSWORD=\|TOKEN=\|private_key' .
grep -rn 'sk-\|ghp_\|gho_\|glpat-\|xoxb-\|xoxp-' .
```

Чеклист:
- [ ] Нет хардкоженных секретов в коде
- [ ] .env в .gitignore
- [ ] .env.example с описанием (без значений!)
- [ ] Секреты на проде через env vars / secrets manager

### 2. Валидация ввода

- [ ] Все пользовательские данные валидируются (Zod, Pydantic, etc.)
- [ ] Белый список, не чёрный
- [ ] Размер загружаемых файлов ограничен
- [ ] Rate limiting на API эндпоинтах

### 3. SQL инъекции

```python
# ❌ Опасно
query = f"SELECT * FROM users WHERE id = {user_id}"

# ✅ Безопасно
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```

- [ ] Все запросы параметризованы или через ORM
- [ ] Нет string interpolation в SQL

### 4. XSS (Cross-Site Scripting)

```javascript
// ❌ Опасно
element.innerHTML = userInput

// ✅ Безопасно
element.textContent = userInput
```

- [ ] Нет innerHTML/dangerouslySetInnerHTML с пользовательским вводом
- [ ] Выходные данные экранируются
- [ ] CSP заголовки настроены

### 5. Аутентификация

- [ ] Пароли хешируются (bcrypt/argon2), НЕ md5/sha
- [ ] JWT с коротким TTL + refresh token
- [ ] Refresh токены в httpOnly cookies
- [ ] Права проверяются на бэкенде, не только на фронте

### 6. CORS и заголовки

```javascript
// ❌ Опасно
cors({ origin: '*' })

// ✅ Безопасно
cors({ origin: 'https://мой-домен.com', credentials: true })
```

- [ ] CORS ограничен конкретными доменами
- [ ] HTTPS обязателен в продакшене
- [ ] Security заголовки (X-Frame-Options, X-Content-Type-Options)

### 7. Зависимости

```bash
npm audit          # Node.js
pip-audit          # Python
safety check       # Python альтернатива
```

- [ ] Нет критических уязвимостей в зависимостях
- [ ] Lock-файл актуален
- [ ] Зависимости обновлены

### 8. Логирование

- [ ] Нет паролей/токенов в логах
- [ ] Нет PII (email, телефон) в логах
- [ ] Ошибки логируются (но без sensitive данных)
- [ ] Есть audit trail для важных операций

## Формат отчёта

```
🔒 Security Audit Report

Проект: [название]
Дата: [дата]
Severity: [N критических / M средних / K низких]

❌ КРИТИЧЕСКИЕ:
1. Хардкоженный API ключ в config.py:23
   → Перенести в .env

⚠️ СРЕДНИЕ:
1. CORS origin: '*' в app.js:45
   → Ограничить доменом

ℹ️ НИЗКИЕ:
1. console.log с user email в auth.js:67
   → Удалить PII из логов

Рекомендации:
- [действие 1]
- [действие 2]
```

## Автоматизация

- **Pre-commit:** security-scan.sh, protect-secrets.sh (hooks)
- **Pre-push:** полная проверка секретов
- **Pre-deploy:** Quality Gate 3 (rules/quality-gates.md)
- **Ежемесячно:** npm audit / pip-audit

## Приоритет при конфликтах

- Безопасность > удобство (ВСЕГДА)
- Критические уязвимости блокируют деплой
- Средние — исправить, но не блокируют
- Низкие — записать в техдолг
- Если пользователь просит пропустить security check → предупредить ДВАЖДЫ
