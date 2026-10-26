
DO $$
BEGIN
    INSERT INTO dishes (restaurant_id, name, price, category_id)
    VALUES (1, 'Блюдо с отрицательной ценой', -100, NULL);
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'Ошибка [CHECK]: Цена блюда должна быть положительным числом. Технический текст: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO orders (user_id, restaurant_id, address_id, status)
    VALUES (999999, 1, 1, 'created');
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Ошибка [FK]: Нельзя создать заказ для несуществующего пользователя (user_id=999999). Технический текст: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO users (email, phone, full_name) VALUES ('ivan@example.com', '+70000000001', 'Дубликат');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Ошибка [UNIQUE]: Пользователь с таким email уже зарегистрирован. Технический текст: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO restaurants (name, address, phone) VALUES (NULL, 'ул. Пример, 1', '+70000000000');
EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE 'Ошибка [NOT NULL]: У ресторана обязательно должно быть название. Технический текст: %', SQLERRM;
END;
$$;

DO $$
DECLARE
    v_courier_id BIGINT;
BEGIN
    SELECT courier_id INTO v_courier_id FROM couriers LIMIT 1;
    INSERT INTO courier_shifts (courier_id, zone) VALUES (v_courier_id, 'Центр');
    INSERT INTO courier_shifts (courier_id, zone) VALUES (v_courier_id, 'Север');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Ошибка [UNIQUE/бизнес-правило]: У курьера уже есть открытая смена. Сначала закройте текущую. Технический текст: %', SQLERRM;
END;
$$;