# hw2-db-food-delivery
Чичварина Алиса ДЭ 15-25 ДЗ_02
## Часть 3. Документирование нарушений целостности

| № | Ограничение | Выполняемый запрос (SQL) | Сообщение СУБД (SQLERRM) | Понятное сообщение для пользователя | Как исправить |
|---|---|---|---|---|---|
| 1 | `CHECK` (constraint `dishes_price_check`) | `INSERT INTO dishes (restaurant_id, name, price, category_id) VALUES (1, 'Блюдо', -100, NULL);` | `new row for relation "dishes" violates check constraint "dishes_price_check"` | «Цена блюда должна быть положительным числом» | Указать значение `price > 0` (например, `199.00`) |
| 2 | `FOREIGN KEY` (`orders.user_id → users.user_id`) | `INSERT INTO orders (user_id, restaurant_id, address_id, status) VALUES (999999, 1, 1, 'created');` | `insert or update on table "orders" violates foreign key constraint "orders_user_id_fkey"` | «Нельзя создать заказ для несуществующего пользователя. Сначала зарегистрируйте его» | Создать пользователя или указать существующий `user_id` |
| 3 | `UNIQUE` (`users.email`) | `INSERT INTO users (email, phone, full_name) VALUES ('ivan@example.com', '+70000000001', 'Дубликат');` | `duplicate key value violates unique constraint "users_email_key"` | «Пользователь с таким email уже зарегистрирован» | Использовать другой email или обновить существующую запись (`UPDATE users ...`) |
| 4 | `NOT NULL` (`restaurants.name`) | `INSERT INTO restaurants (name, address, phone) VALUES (NULL, 'ул. Пример, 1', '+70000000000');` | `null value in column "name" of relation "restaurants" violates not-null constraint` | «У ресторана обязательно должно быть название» | Передать непустое `name` (например, `'Пиццерия №1'`) |
| 5 | Частичный `UNIQUE` (`uq_courier_shifts_open`) — бизнес-правило «одна открытая смена» | `INSERT INTO courier_shifts (courier_id, zone) VALUES (1, 'Центр');`<br>`INSERT INTO courier_shifts (courier_id, zone) VALUES (1, 'Север');` | `duplicate key value violates unique constraint "uq_courier_shifts_open"` | «У курьера уже есть открытая смена — сначала закройте текущую» | `UPDATE courier_shifts SET ended_at = now() WHERE courier_id = 1 AND ended_at IS NULL;` |

### Краткие выводы
- **CHECK** — дешёвая защита от «невозможных» значений (отрицательная цена, неверный рейтинг).
- **FOREIGN KEY** — обеспечивает ссылочную целостность. Нельзя создать заказ на несуществующего пользователя.
- **UNIQUE** — защищает бизнес-ключи (email) и бизнес-правила (одна открытая смена у курьера).
- **NOT NULL** — гарантирует наличие обязательных атрибутов (название ресторана, цена блюда).
- Все сообщения содержат и бизнес-смысл, и технический `SQLERRM` для разработчиков.
