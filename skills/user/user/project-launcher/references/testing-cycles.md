# Testing Cycles

Complete testing strategy for all levels of the project.

## Overview

Multi-level testing ensures quality at every stage:
- **Task level:** Immediate feedback
- **Feature level:** Integration validation
- **Phase level:** End-to-end scenarios
- **Project level:** Full acceptance

---

## After TASK

### Automated Tests

**Unit Tests:**
- Test individual functions/methods in isolation
- Mock external dependencies
- Coverage target: 80%+

**Integration Tests:**
- Test component interactions
- Use test database
- Verify data flows

**Security Scan:**
- Check for common vulnerabilities
- Validate input sanitization
- Review authentication/authorization

### Manual Actions

None at task level - fully automated

---

## After FEATURE

### Automated Tests

All task-level tests PLUS:

**Feature Tests:**
- Test complete user workflows
- Verify business logic
- Check edge cases

**Regression Tests:**
- Ensure previous features still work
- Run against existing test suite

**Performance Check:**
- Response time benchmarks
- Memory usage validation
- Query optimization check

**Security:**
- Full security scan

### Manual Test Plan

**Generate:** `docs/test-plans/feature-{name}.md`

**Contents:**
```markdown
# Feature Test Plan: {Feature Name}

## Overview
[What this feature does]

## Prerequisites
- [ ] Development environment set up
- [ ] Test data prepared

## Test Scenarios

### Scenario 1: Happy Path
**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result:**
[What should happen]

**Actual Result:**
[ ] Pass / [ ] Fail

---

### Scenario 2: Error Handling
[Similar structure]

---

## Edge Cases
[List of edge cases to test]

## Checklist
- [ ] All scenarios passed
- [ ] Edge cases handled
- [ ] Error messages clear
- [ ] Performance acceptable
```

**Provide to User:**
Output the test plan for manual verification

---

## After PHASE (Block)

### Automated Tests

All previous tests PLUS:

**Full Integration:**
- Test all components together
- Verify cross-feature interactions
- Check data consistency

**E2E Tests:**
- Simulate complete user journeys
- Use tools like Playwright/Cypress for web
- Use real bot interactions for Telegram bots

**Load Testing** (if applicable):
- Concurrent user simulation
- Performance under load
- Resource usage monitoring

**Security Audit:**
- Comprehensive security review
- Penetration testing if needed

### Manual Test Plan

**Generate:** `docs/test-plans/phase-{N}-{name}.md`

**Contents:**
```markdown
# Phase Test Plan: Phase {N} - {Name}

## Features in This Phase
1. Feature A
2. Feature B
3. Feature C

## Integration Tests

### Integration 1: Feature A + Feature B
**Test:** [What to test]
**Steps:**
1. [Step]
2. [Step]

**Expected:** [Result]
**Status:** [ ] Pass / [ ] Fail

---

## End-to-End Scenarios

### E2E 1: Complete User Flow
**Scenario:** User signs up and completes first task
**Steps:**
1. [Detailed steps]
2. [...]

**Expected Outcome:**
[What should happen at each step]

**Status:** [ ] Pass / [ ] Fail

---

## Performance Tests

### Load Test 1: Concurrent Users
**Test:** 50 concurrent users
**Expected:** Response time < 200ms
**Actual:** _____
**Status:** [ ] Pass / [ ] Fail

---

## Security Checks
- [ ] Authentication works
- [ ] Authorization enforced
- [ ] Input validation
- [ ] No SQL injection
- [ ] XSS protected

## Sign-off
Phase {N} ready for deployment: [ ] Yes / [ ] No
Issues found: _______________
```

**Provide to User:**
Output for thorough manual testing before moving forward

---

## After PROJECT

### Automated Tests

**Full Test Suite:**
- Run ALL tests (unit, integration, feature, E2E)
- Ensure 100% pass rate

**Smoke Tests:**
- Critical path validation
- Can the app start?
- Can users perform core actions?

**Security Audit:**
- Final security review
- Vulnerability scan
- Compliance check (if applicable)

**Performance Benchmarks:**
- Response times
- Memory usage
- Database query performance
- API throughput (if applicable)

**Code Quality Report:**
- Linting results
- Code coverage
- Complexity metrics
- Technical debt assessment

### Final Acceptance Test Plan

**Generate:** `docs/test-plans/FINAL-ACCEPTANCE.md`

**Contents:**
```markdown
# Final Acceptance Test Plan: {Project Name}

## Project Overview
[Brief description]

## Test Environment
- [ ] Production-like environment prepared
- [ ] Test data loaded
- [ ] All dependencies configured

---

## Critical Path Tests

### Test 1: User Registration & First Action
**Importance:** CRITICAL
**Steps:**
1. [Complete user journey]
2. [...]

**Expected:** [Outcome]
**Status:** [ ] Pass / [ ] Fail
**Notes:** _______________

---

### Test 2: [Next Critical Path]
[Similar structure]

---

## Feature Acceptance

### Feature: {Feature Name}
- [ ] All scenarios pass
- [ ] Performance acceptable
- [ ] Security validated
- [ ] Documentation complete

[Repeat for all features]

---

## Non-Functional Requirements

### Performance
- [ ] Response times < {target}
- [ ] Handles {N} concurrent users
- [ ] Memory usage acceptable

### Security
- [ ] All vulnerabilities addressed
- [ ] Authentication/authorization working
- [ ] Data encryption enabled
- [ ] Logging/monitoring active

### Reliability
- [ ] Error handling comprehensive
- [ ] Graceful degradation
- [ ] Auto-recovery mechanisms

### Usability
- [ ] User flows intuitive
- [ ] Error messages clear
- [ ] Help/documentation accessible

---

## Deployment Readiness

### Infrastructure
- [ ] Production environment ready
- [ ] Database migrations tested
- [ ] Backups configured
- [ ] Monitoring alerts set up

### Documentation
- [ ] README complete
- [ ] API docs (if applicable)
- [ ] Deployment guide
- [ ] Troubleshooting guide

### Sign-off
- [ ] All tests passed
- [ ] No critical issues
- [ ] Team approval obtained

**Project Status:** [ ] Ready for Production / [ ] Needs Work

**Outstanding Issues:**
1. _______________
2. _______________

**Sign-off Date:** __________
**Signed by:** ______________
```

**Provide to User:**
Comprehensive acceptance test plan for final validation before going live

---

## Testing Tools

### Unit/Integration
- **Python:** pytest, unittest
- **Node.js:** Jest, Mocha
- **Go:** testing package

### E2E
- **Web:** Playwright, Cypress, Selenium
- **Mobile:** Appium, Detox
- **Bots:** Direct API testing

### Performance
- **Load testing:** k6, Apache JMeter, Locust
- **Profiling:** Python cProfile, Node.js clinic

### Security
- **SAST:** Bandit (Python), ESLint (JS)
- **DAST:** OWASP ZAP
- **Dependencies:** Safety (Python), npm audit (Node)

---

## Best Practices

**1. Test Pyramid**
```
     /\
    /E2E\        ← Few (slow, expensive)
   /------\
  /Integration\ ← Some (medium)
 /------------\
/  Unit Tests  \ ← Many (fast, cheap)
```

**2. Always Red-Green-Refactor**
- Write test FIRST (RED)
- Make it pass (GREEN)
- Improve code (REFACTOR)

**3. Test Independence**
- Each test should run in isolation
- No test should depend on another
- Order shouldn't matter

**4. Meaningful Assertions**
- Test behavior, not implementation
- Clear failure messages
- One concept per test

**5. Keep Tests Fast**
- Unit tests: milliseconds
- Integration: seconds
- E2E: minutes
- Optimize slow tests

---

## When Tests Fail

**1. Understand the Failure**
- Read error message carefully
- Check stack trace
- Reproduce locally

**2. Fix Root Cause**
- Don't just make test pass
- Fix the actual bug
- Add regression test if needed

**3. Document if Complex**
- Add to problems-log
- Update troubleshooting docs
- Share with team

**4. Rerun Full Suite**
- Ensure no other tests affected
- Check for regressions
- Validate fix thoroughly
