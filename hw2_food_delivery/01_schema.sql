CREATE TABLE IF NOT EXISTS users (
    user_id   BIGSERIAL PRIMARY KEY,
    email     VARCHAR(255) NOT NULL UNIQUE,
    phone     VARCHAR(20)  NOT NULL,
    full_name VARCHAR(200) NOT NULL
);
CREATE TABLE IF NOT EXISTS couriers (
    courier_id BIGSERIAL PRIMARY KEY,
    full_name  VARCHAR(200) NOT NULL,
    phone      VARCHAR(20)  NOT NULL,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE IF NOT EXISTS restaurants (
    restaurant_id BIGSERIAL PRIMARY KEY,
    name          VARCHAR(200) NOT NULL,
    address       VARCHAR(300) NOT NULL,
    phone         VARCHAR(20)  NOT NULL,
    rating_avg    NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (rating_avg BETWEEN 0 AND 5)
);
CREATE TABLE IF NOT EXISTS dish_categories (
    category_id BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    sort_order  INT NOT NULL DEFAULT 100
);
CREATE TABLE IF NOT EXISTS addresses (
    address_id BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    city       VARCHAR(100) NOT NULL,
    street     VARCHAR(200) NOT NULL
);
CREATE TABLE IF NOT EXISTS dishes (
    dish_id       BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    name          VARCHAR(200) NOT NULL,
    price         NUMERIC(10,2) NOT NULL CHECK (price > 0),
    category_id   BIGINT REFERENCES dish_categories(category_id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS courier_shifts (
    shift_id   BIGSERIAL PRIMARY KEY,
    courier_id BIGINT NOT NULL REFERENCES couriers(courier_id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at   TIMESTAMPTZ,
    zone       VARCHAR(100),
    CONSTRAINT chk_courier_shifts_period CHECK (ended_at IS NULL OR ended_at > started_at)
);
CREATE TABLE IF NOT EXISTS courier_restaurants (
    courier_id    BIGINT NOT NULL REFERENCES couriers(courier_id) ON DELETE CASCADE,
    restaurant_id BIGINT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    assigned_at   DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (courier_id, restaurant_id)
);
CREATE TABLE IF NOT EXISTS orders (
    order_id      BIGSERIAL PRIMARY KEY,
    user_id       BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    restaurant_id BIGINT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE RESTRICT,
    courier_id    BIGINT REFERENCES couriers(courier_id) ON DELETE SET NULL,
    address_id    BIGINT NOT NULL REFERENCES addresses(address_id) ON DELETE RESTRICT,
    status        VARCHAR(20) NOT NULL DEFAULT 'created'
        CHECK (status IN ('created','accepted','cooking','delivering','delivered','cancelled')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    delivered_at  TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id      BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    dish_id       BIGINT NOT NULL REFERENCES dishes(dish_id) ON DELETE RESTRICT,
    quantity      INT NOT NULL CHECK (quantity > 0),
    price_at_order NUMERIC(10,2) NOT NULL CHECK (price_at_order > 0)
);
CREATE TABLE IF NOT EXISTS reviews (
    review_id     BIGSERIAL PRIMARY KEY,
    user_id       BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    restaurant_id BIGINT REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    courier_id    BIGINT REFERENCES couriers(courier_id) ON DELETE SET NULL,
    rating        INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_reviews_target CHECK (restaurant_id IS NOT NULL OR courier_id IS NOT NULL)
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_courier_shifts_open ON courier_shifts (courier_id) WHERE ended_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_dish_categories_sort ON dish_categories (sort_order, name);
CREATE INDEX IF NOT EXISTS idx_courier_shifts_courier_started ON courier_shifts (courier_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_courier_restaurants_rest ON courier_restaurants (restaurant_id, courier_id);
CREATE INDEX IF NOT EXISTS idx_orders_restaurant_created ON orders (restaurant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_orders_restaurant_delivered ON orders (restaurant_id, delivered_at) WHERE delivered_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_orders_courier_created ON orders (courier_id, created_at) WHERE courier_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_orders_user_created ON orders (user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_dish ON order_items (dish_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_dishes_restaurant_cat_name ON dishes (restaurant_id, category_id, name);
CREATE INDEX IF NOT EXISTS idx_couriers_active ON couriers (courier_id) WHERE is_active;
CREATE INDEX IF NOT EXISTS idx_reviews_restaurant_created ON reviews (restaurant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_courier_created ON reviews (courier_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses (user_id);