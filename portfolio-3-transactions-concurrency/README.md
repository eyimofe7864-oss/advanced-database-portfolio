# Portfolio 3 – Transactions and Concurrency (Wakawell)

## Files in this folder
| File | Contents |
|---|---|
| `portfolio-3-transactions.sql` | Admin A script: COMMIT, ROLLBACK, constraint test, locking steps |
| `portfolio-3-admin-b.sql` | Admin B script, run in a second connection for the concurrency test |
| `1-commit-new-route.png` | New route saved with COMMIT |
| `2-rollback-inside-transaction.png` / `3-rollback-after.png` | Route visible inside the transaction, gone after ROLLBACK |
| `4-check-constraint-blocks-zero-fare.png` | CHECK constraint rejecting a ₦0 fare |
| `5-admin-b-waiting-on-lock.png` | Admin B blocked while Admin A holds the lock |
| `6-admin-b-timeout-then-reads-1300.png` | Admin B times out, then reads Admin A's saved value |
| `7-final-fare-1350.png` | Final fare showing both admins' changes were kept |

## 1. COMMIT – adding a route as one unit of work
A transaction is all or nothing. Adding the "Kubwa – Area 1 Express" route required
inserting the route, its 3 stops and its 3 fares. These were grouped in one transaction
and saved with **COMMIT**. If the route had saved but its stops had not, riders would see
a broken route with no stops. This all-or-nothing rule is **atomicity**, the A in ACID.

## 2. ROLLBACK – cancelling a mistake
An administrator started adding a "Kubwa – Area 1 Keke" route, then cancelled it with
**ROLLBACK**. Inside the transaction, the Keke route was visible. After ROLLBACK, both the
route and its stops were gone, as if the change had never happened (0 stops remained).

## 3. Constraints still apply inside transactions
Inserting a fare of ₦0 was rejected with *"Check constraint 'fares_chk_1' is violated"*.
The CHECK (amount > 0) rule from Portfolio 1 protects data **consistency** (the C in ACID)
whether or not a transaction is used.

## 4. Two-admin test – preventing a lost update
**Scenario:** two administrators edit the Kubwa Village → Berger Junction fare (₦1,200)
at the same time. MySQL's default isolation level, **REPEATABLE READ**, was used.

| Step | Admin A | Admin B |
|---|---|---|
| 1 | Starts a transaction and locks the fare row with `SELECT … FOR UPDATE` | — |
| 2 | Changes the fare to ₦1,300 (not yet saved) | — |
| 3 | — | Tries to lock the same row and **has to wait** |
| 4 | Commits, which releases the lock | Waited 30 seconds, then the Workbench client timed out |
| 5 | — | Retried, read the **updated ₦1,300**, added ₦50 and committed |

**Final fare: ₦1,350**, so both changes were kept.

**Why the lock matters:** without it, both admins would read ₦1,200. Whoever saved last
would overwrite the other's change, and that update would be silently lost (a
**lost update**). Riders could then see the wrong fare. The lock makes Admin B wait until
Admin A has finished, so B builds on A's saved value instead of an out-of-date one. This
protects **isolation**, the I in ACID.

**Note on the timeout:** Admin B's first attempt ended after 30 seconds because of
MySQL Workbench's default read timeout, not because the database failed. It shows the
lock working: B could not change the fare while A held it.
