import '../domain/models/sql_problem.dart';

const List<String> kSqlTables = ['users', 'products', 'orders'];

const String kSqlSeed = '''
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  city TEXT NOT NULL
);
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  category TEXT
);
CREATE TABLE orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  order_date TEXT NOT NULL
);

INSERT INTO users (id, name, age, city) VALUES
  (1, 'Kim', 25, 'Seoul'),
  (2, 'Lee', 31, 'Busan'),
  (3, 'Park', 19, 'Seoul'),
  (4, 'Choi', 42, 'Daegu'),
  (5, 'Jung', 28, 'Busan'),
  (6, 'Kang', 35, 'Seoul'),
  (7, 'Yoon', 23, 'Incheon');

INSERT INTO products (id, name, price, category) VALUES
  (1, 'Keyboard', 89000, 'Device'),
  (2, 'Mouse', 35000, 'Device'),
  (3, 'Monitor', 320000, 'Device'),
  (4, 'Notebook', 4500, 'Office'),
  (5, 'Pen', 1200, 'Office'),
  (6, 'Chair', 210000, 'Furniture'),
  (7, 'Gift Card', 50000, NULL);

INSERT INTO orders (id, user_id, product_id, quantity, order_date) VALUES
  (1, 1, 1, 1, '2026-01-05'),
  (2, 1, 5, 10, '2026-01-05'),
  (3, 2, 3, 2, '2026-01-12'),
  (4, 3, 2, 1, '2026-02-01'),
  (5, 4, 6, 1, '2026-02-14'),
  (6, 5, 4, 5, '2026-02-20'),
  (7, 6, 1, 2, '2026-03-03'),
  (8, 2, 2, 3, '2026-03-09');
''';

const List<String> kSqlCategories = [
  'SELECT 기본',
  'WHERE 조건',
  '정렬과 개수 제한',
  '집계 함수',
  'GROUP BY',
  'JOIN',
  '데이터 변경',
];

const List<SqlProblem> kSqlProblems = [
  SqlProblem(
    id: 'select-all',
    category: 'SELECT 기본',
    title: '모든 컬럼 조회',
    description: 'users 테이블의 모든 컬럼과 모든 행을 조회하세요.',
    answerSql: 'SELECT * FROM users',
  ),
  SqlProblem(
    id: 'select-columns',
    category: 'SELECT 기본',
    title: '원하는 컬럼만 조회',
    description: 'products 테이블에서 name과 price만 조회하세요.',
    answerSql: 'SELECT name, price FROM products',
  ),
  SqlProblem(
    id: 'select-distinct',
    category: 'SELECT 기본',
    title: '중복 제거',
    description: '회원들이 사는 도시(city)를 중복 없이 조회하세요.',
    answerSql: 'SELECT DISTINCT city FROM users',
  ),
  SqlProblem(
    id: 'where-age',
    category: 'WHERE 조건',
    title: '비교 연산자',
    description: '나이(age)가 30 이상인 회원의 name과 age를 조회하세요.',
    answerSql: 'SELECT name, age FROM users WHERE age >= 30',
  ),
  SqlProblem(
    id: 'where-city',
    category: 'WHERE 조건',
    title: '문자열 비교',
    description: "city가 'Seoul'인 회원의 모든 컬럼을 조회하세요.",
    answerSql: "SELECT * FROM users WHERE city = 'Seoul'",
  ),
  SqlProblem(
    id: 'where-and',
    category: 'WHERE 조건',
    title: 'AND',
    description: "city가 'Seoul'이고 나이가 30 미만인 회원의 name을 조회하세요.",
    answerSql: "SELECT name FROM users WHERE city = 'Seoul' AND age < 30",
  ),
  SqlProblem(
    id: 'where-or',
    category: 'WHERE 조건',
    title: 'OR / IN',
    description: "city가 'Busan'이거나 'Daegu'인 회원의 name과 city를 조회하세요.",
    answerSql: "SELECT name, city FROM users WHERE city IN ('Busan', 'Daegu')",
  ),
  SqlProblem(
    id: 'where-between',
    category: 'WHERE 조건',
    title: '범위 조건',
    description: '가격(price)이 10000 이상 100000 이하인 상품의 name과 price를 조회하세요.',
    answerSql:
        'SELECT name, price FROM products WHERE price BETWEEN 10000 AND 100000',
  ),
  SqlProblem(
    id: 'where-like',
    category: 'WHERE 조건',
    title: 'LIKE',
    description: "이름(name)이 'K'로 시작하는 회원의 name을 조회하세요.",
    answerSql: "SELECT name FROM users WHERE name LIKE 'K%'",
  ),
  SqlProblem(
    id: 'where-null',
    category: 'WHERE 조건',
    title: 'NULL 확인',
    description: 'category가 비어 있는(NULL) 상품의 name을 조회하세요.',
    answerSql: 'SELECT name FROM products WHERE category IS NULL',
  ),
  SqlProblem(
    id: 'order-asc',
    category: '정렬과 개수 제한',
    title: 'ORDER BY',
    description: '회원의 name과 age를 나이가 어린 순서대로 조회하세요.',
    answerSql: 'SELECT name, age FROM users ORDER BY age',
    ordered: true,
  ),
  SqlProblem(
    id: 'order-limit',
    category: '정렬과 개수 제한',
    title: 'ORDER BY와 LIMIT',
    description: '가격(price)이 비싼 순서대로 상품 3개의 name과 price를 조회하세요.',
    answerSql: 'SELECT name, price FROM products ORDER BY price DESC LIMIT 3',
    ordered: true,
  ),
  SqlProblem(
    id: 'order-where',
    category: '정렬과 개수 제한',
    title: '조건과 정렬 함께 쓰기',
    description: "category가 'Device'인 상품의 name과 price를 가격이 낮은 순서대로 조회하세요.",
    answerSql:
        "SELECT name, price FROM products WHERE category = 'Device' ORDER BY price",
    ordered: true,
  ),
  SqlProblem(
    id: 'order-multi',
    category: '정렬과 개수 제한',
    title: '여러 기준으로 정렬',
    description:
        '회원의 name, city, age를 city 오름차순으로 정렬하고, 같은 city 안에서는 나이가 많은 순서대로 조회하세요.',
    answerSql: 'SELECT name, city, age FROM users ORDER BY city, age DESC',
    ordered: true,
  ),
  SqlProblem(
    id: 'count-all',
    category: '집계 함수',
    title: 'COUNT',
    description: '전체 회원 수를 조회하세요.',
    answerSql: 'SELECT COUNT(*) FROM users',
  ),
  SqlProblem(
    id: 'count-where',
    category: '집계 함수',
    title: '조건과 COUNT',
    description: "city가 'Seoul'인 회원 수를 조회하세요.",
    answerSql: "SELECT COUNT(*) FROM users WHERE city = 'Seoul'",
  ),
  SqlProblem(
    id: 'agg-max',
    category: '집계 함수',
    title: 'MAX',
    description: '가장 비싼 상품의 가격(price)을 조회하세요.',
    answerSql: 'SELECT MAX(price) FROM products',
  ),
  SqlProblem(
    id: 'agg-sum',
    category: '집계 함수',
    title: 'SUM',
    description: '모든 주문의 수량(quantity) 합계를 조회하세요.',
    answerSql: 'SELECT SUM(quantity) FROM orders',
  ),
  SqlProblem(
    id: 'agg-avg',
    category: '집계 함수',
    title: 'AVG',
    description: '회원의 평균 나이를 조회하세요.',
    answerSql: 'SELECT AVG(age) FROM users',
  ),
  SqlProblem(
    id: 'group-city',
    category: 'GROUP BY',
    title: '그룹별 개수',
    description: '도시(city)별 회원 수를 조회하세요. 컬럼은 city, 회원 수 순서로 출력합니다.',
    answerSql: 'SELECT city, COUNT(*) FROM users GROUP BY city',
  ),
  SqlProblem(
    id: 'group-user-sum',
    category: 'GROUP BY',
    title: '그룹별 합계',
    description:
        '회원(user_id)별 주문 수량(quantity) 합계를 조회하세요. 컬럼은 user_id, 수량 합계 순서로 출력합니다.',
    answerSql: 'SELECT user_id, SUM(quantity) FROM orders GROUP BY user_id',
  ),
  SqlProblem(
    id: 'group-product-count',
    category: 'GROUP BY',
    title: '그룹별 건수',
    description:
        '상품(product_id)별 주문 건수를 조회하세요. 컬럼은 product_id, 주문 건수 순서로 출력합니다.',
    answerSql: 'SELECT product_id, COUNT(*) FROM orders GROUP BY product_id',
  ),
  SqlProblem(
    id: 'group-having',
    category: 'GROUP BY',
    title: 'HAVING',
    description: '회원이 2명 이상인 도시의 city와 회원 수를 조회하세요.',
    answerSql:
        'SELECT city, COUNT(*) FROM users GROUP BY city HAVING COUNT(*) >= 2',
  ),
  SqlProblem(
    id: 'join-basic',
    category: 'JOIN',
    title: '두 테이블 연결',
    description: '각 주문의 id와 주문한 회원의 name을 조회하세요. 컬럼은 주문 id, 회원 name 순서로 출력합니다.',
    answerSql:
        'SELECT orders.id, users.name FROM orders JOIN users ON orders.user_id = users.id',
  ),
  SqlProblem(
    id: 'join-product',
    category: 'JOIN',
    title: '상품 정보 붙이기',
    description: '각 주문의 id, 주문한 상품의 name, 수량(quantity)을 조회하세요.',
    answerSql:
        'SELECT orders.id, products.name, orders.quantity FROM orders JOIN products ON orders.product_id = products.id',
  ),
  SqlProblem(
    id: 'join-where',
    category: 'JOIN',
    title: 'JOIN과 조건',
    description: "이름이 'Lee'인 회원이 주문한 상품의 name을 조회하세요.",
    answerSql:
        "SELECT products.name FROM orders JOIN users ON orders.user_id = users.id JOIN products ON orders.product_id = products.id WHERE users.name = 'Lee'",
  ),
  SqlProblem(
    id: 'join-three',
    category: 'JOIN',
    title: '세 테이블 연결',
    description: '각 주문에 대해 회원 name, 상품 name, 수량(quantity)을 조회하세요.',
    answerSql:
        'SELECT users.name, products.name, orders.quantity FROM orders JOIN users ON orders.user_id = users.id JOIN products ON orders.product_id = products.id',
  ),
  SqlProblem(
    id: 'join-left',
    category: 'JOIN',
    title: 'LEFT JOIN',
    description:
        '모든 회원의 name과 그 회원의 주문 id를 조회하세요. 주문이 없는 회원도 포함하고, 그 경우 주문 id는 NULL로 출력합니다.',
    answerSql:
        'SELECT users.name, orders.id FROM users LEFT JOIN orders ON orders.user_id = users.id',
  ),
  SqlProblem(
    id: 'join-group',
    category: 'JOIN',
    title: 'JOIN과 집계',
    description: '주문한 적이 있는 회원의 name과 총 주문 금액(price × quantity의 합계)을 조회하세요.',
    answerSql:
        'SELECT users.name, SUM(products.price * orders.quantity) FROM orders JOIN users ON orders.user_id = users.id JOIN products ON orders.product_id = products.id GROUP BY users.id',
  ),
  SqlProblem(
    id: 'insert-user',
    category: '데이터 변경',
    title: 'INSERT',
    description:
        "users 테이블에 name 'Han', age 27, city 'Seoul'인 회원을 추가하세요. id는 자동으로 부여됩니다.",
    answerSql:
        "INSERT INTO users (name, age, city) VALUES ('Han', 27, 'Seoul')",
    targetTable: 'users',
  ),
  SqlProblem(
    id: 'insert-product',
    category: '데이터 변경',
    title: 'INSERT 한 번 더',
    description:
        "products 테이블에 name 'Desk', price 150000, category 'Furniture'인 상품을 추가하세요. id는 자동으로 부여됩니다.",
    answerSql:
        "INSERT INTO products (name, price, category) VALUES ('Desk', 150000, 'Furniture')",
    targetTable: 'products',
  ),
  SqlProblem(
    id: 'update-city',
    category: '데이터 변경',
    title: 'UPDATE',
    description: "id가 3인 회원의 city를 'Busan'으로 변경하세요.",
    answerSql: "UPDATE users SET city = 'Busan' WHERE id = 3",
    targetTable: 'users',
  ),
  SqlProblem(
    id: 'update-price',
    category: '데이터 변경',
    title: '계산해서 UPDATE',
    description: "category가 'Office'인 상품의 가격(price)을 1000씩 올리세요.",
    answerSql:
        "UPDATE products SET price = price + 1000 WHERE category = 'Office'",
    targetTable: 'products',
  ),
  SqlProblem(
    id: 'delete-order',
    category: '데이터 변경',
    title: 'DELETE',
    description: 'id가 8인 주문을 삭제하세요.',
    answerSql: 'DELETE FROM orders WHERE id = 8',
    targetTable: 'orders',
  ),
  SqlProblem(
    id: 'delete-where',
    category: '데이터 변경',
    title: '조건으로 DELETE',
    description: '수량(quantity)이 1인 주문을 모두 삭제하세요.',
    answerSql: 'DELETE FROM orders WHERE quantity = 1',
    targetTable: 'orders',
  ),
];
