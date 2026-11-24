-- AI Beauty Assistant: деректер қорының схемасы (PostgreSQL)
-- Кестелер DFD қоймаларына сәйкес: D1 users, D2 skin_analyses, D3 recommendations,
-- D4 products, D5 ingredients, D6 favorites, D7 product_ingredients.

-- ============ 1. КЕСТЕЛЕРДІ ҚҰРУ (DDL) ============

CREATE TABLE users (
    user_id        SERIAL PRIMARY KEY,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    role           VARCHAR(10)  NOT NULL CHECK (role IN ('client', 'expert', 'admin')),
    birth_year     INT,
    reminder_time  TIME,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE skin_analyses (
    analysis_id         SERIAL PRIMARY KEY,
    user_id             INT          NOT NULL,
    photo_path          VARCHAR(255) NOT NULL,
    status              VARCHAR(10)  NOT NULL CHECK (status IN ('success', 'failed')),
    skin_type           VARCHAR(20),
    hydration_level     INT CHECK (hydration_level BETWEEN 0 AND 100),
    acne_level          INT CHECK (acne_level BETWEEN 0 AND 3),
    pigmentation_level  INT CHECK (pigmentation_level BETWEEN 0 AND 3),
    wrinkle_level       INT CHECK (wrinkle_level BETWEEN 0 AND 3),
    analyzed_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE TABLE products (
    product_id           SERIAL PRIMARY KEY,
    name                 VARCHAR(150) NOT NULL,
    brand                VARCHAR(80)  NOT NULL,
    category             VARCHAR(50)  NOT NULL,
    barcode              VARCHAR(20)  UNIQUE,
    suitable_skin_type   VARCHAR(20)  NOT NULL
);

CREATE TABLE ingredients (
    ingredient_id  SERIAL PRIMARY KEY,
    name           VARCHAR(100) NOT NULL UNIQUE,
    description    TEXT,
    is_irritant    BOOLEAN      NOT NULL DEFAULT FALSE
);

-- M:N байланыс (products - ingredients) аралық кесте арқылы
CREATE TABLE product_ingredients (
    product_id     INT NOT NULL,
    ingredient_id  INT NOT NULL,
    PRIMARY KEY (product_id, ingredient_id),
    FOREIGN KEY (product_id)    REFERENCES products (product_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (ingredient_id)
);

CREATE TABLE recommendations (
    recommendation_id  SERIAL PRIMARY KEY,
    analysis_id        INT         NOT NULL,
    product_id         INT         NOT NULL,
    routine_time       VARCHAR(10) NOT NULL CHECK (routine_time IN ('morning', 'evening')),
    step_order         INT         NOT NULL,
    created_at         TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (analysis_id) REFERENCES skin_analyses (analysis_id),
    FOREIGN KEY (product_id)  REFERENCES products (product_id)
);

-- M:N байланыс (users - products) аралық кесте арқылы
CREATE TABLE favorites (
    user_id     INT       NOT NULL,
    product_id  INT       NOT NULL,
    added_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id)    REFERENCES users (user_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- ============ 2. ТЕСТІЛІК ДЕРЕКТЕР (INSERT) ============

INSERT INTO users (user_id, full_name, email, password_hash, role, birth_year, reminder_time) VALUES
(1, 'Аружан Сейітқызы',   'aruzhan@example.kz', 'hash_a1', 'client', 2002, '08:00'),
(2, 'Мадина Ермекқызы',   'madina@example.kz',  'hash_a2', 'client', 1998, '21:30'),
(3, 'Айгерім Нұрланқызы', 'aigerim@example.kz', 'hash_a3', 'client', 2000, NULL),
(4, 'Динара Болатқызы',   'dinara@example.kz',  'hash_e1', 'expert', 1990, NULL),
(5, 'Нұрлан Әлібеков',    'admin@example.kz',   'hash_ad', 'admin',  1992, NULL);

INSERT INTO skin_analyses (analysis_id, user_id, photo_path, status, skin_type, hydration_level, acne_level, pigmentation_level, wrinkle_level, analyzed_at) VALUES
(1, 1, 'photos/u1_001.jpg', 'success', 'oily',        42, 2, 1, 0, '2026-11-10 09:15'),
(2, 2, 'photos/u2_001.jpg', 'success', 'dry',         28, 0, 1, 1, '2026-11-11 20:40'),
(3, 3, 'photos/u3_001.jpg', 'failed',   NULL,       NULL, NULL, NULL, NULL, '2026-11-12 11:05'),
(4, 3, 'photos/u3_002.jpg', 'success', 'combination', 55, 1, 0, 0, '2026-11-12 11:07'),
(5, 1, 'photos/u1_002.jpg', 'success', 'oily',        47, 1, 1, 0, '2026-11-20 08:50');

INSERT INTO products (product_id, name, brand, category, barcode, suitable_skin_type) VALUES
(1, 'Gel Cleanser',          'CeraVe',        'cleanser',    '3337875597',  'oily'),
(2, 'Hydrating Cream',       'La Roche-Posay','moisturizer', '3337872413',  'dry'),
(3, 'Niacinamide Serum 10%', 'The Ordinary',  'serum',       '7690071011',  'combination'),
(4, 'Sunscreen SPF 50',      'Bioderma',      'sunscreen',   '3701129801',  'all'),
(5, 'Salicylic Toner',       'COSRX',         'toner',       '8809416470',  'oily');

INSERT INTO ingredients (ingredient_id, name, description, is_irritant) VALUES
(1, 'Niacinamide',       'Саңылауды тарылтады, майлылықты реттейді', FALSE),
(2, 'Hyaluronic Acid',   'Теріні терең ылғалдандырады',              FALSE),
(3, 'Salicylic Acid',    'Акнеге қарсы, тері тазалағыш',             TRUE),
(4, 'Ceramides',         'Тері тосқауылын қалпына келтіреді',        FALSE),
(5, 'Fragrance',         'Хош иісті қоспа, аллергия тудыруы мүмкін', TRUE);

INSERT INTO product_ingredients (product_id, ingredient_id) VALUES
(1, 4), (2, 2), (2, 4), (3, 1), (5, 3);

INSERT INTO recommendations (recommendation_id, analysis_id, product_id, routine_time, step_order, created_at) VALUES
(1, 1, 1, 'morning', 1, '2026-11-10 09:16'),
(2, 1, 5, 'evening', 1, '2026-11-10 09:16'),
(3, 2, 2, 'evening', 1, '2026-11-11 20:41'),
(4, 4, 3, 'morning', 2, '2026-11-12 11:08'),
(5, 4, 4, 'morning', 3, '2026-11-12 11:08');

INSERT INTO favorites (user_id, product_id, added_at) VALUES
(1, 1, '2026-11-10 09:30'),
(1, 5, '2026-11-10 09:31'),
(2, 2, '2026-11-11 20:50'),
(3, 3, '2026-11-12 11:20');

-- ============ 3. СҰРАНЫСТАР ============

-- Сұраныс 1 (JOIN, 4 кесте): әр клиентке ұсынылған күтім құралдары
SELECT u.full_name,
       a.skin_type,
       r.routine_time,
       r.step_order,
       p.name AS product_name,
       p.brand
FROM users u
JOIN skin_analyses  a ON a.user_id     = u.user_id
JOIN recommendations r ON r.analysis_id = a.analysis_id
JOIN products       p ON p.product_id  = r.product_id
WHERE a.status = 'success'
ORDER BY u.full_name, r.routine_time, r.step_order;

-- Сұраныс 2 (GROUP BY): тері типі бойынша сәтті талдаулар саны және орташа ылғалдылық
SELECT skin_type,
       COUNT(*)                          AS analyses_count,
       ROUND(AVG(hydration_level), 1)    AS avg_hydration
FROM skin_analyses
WHERE status = 'success'
GROUP BY skin_type
ORDER BY analyses_count DESC, skin_type;

-- Сұраныс 3 (JOIN 3 кесте + GROUP BY): өнімнің «Таңдаулылар» және ингредиент саны
SELECT p.name AS product_name,
       COUNT(DISTINCT f.user_id)        AS favorites_count,
       COUNT(DISTINCT pi.ingredient_id) AS ingredients_count
FROM products p
LEFT JOIN favorites           f  ON f.product_id  = p.product_id
LEFT JOIN product_ingredients pi ON pi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY favorites_count DESC, p.name;
