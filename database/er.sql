
#### Customer
```sql
Customer (
  Customer_ID    INT PRIMARY KEY AUTO_INCREMENT,
  Name           VARCHAR(100),
  Email          VARCHAR(100),
  Phone_Number   VARCHAR(20),
  Address        VARCHAR(255)
)
```

#### Restaurant
```sql
Restaurant (
  Restaurant_ID  INT PRIMARY KEY AUTO_INCREMENT,
  Name           VARCHAR(100),
  Location       VARCHAR(255),
  Cuisine_Type   VARCHAR(50)
)
```

#### Menu_Item
```sql
Menu_Item (
  Item_ID        INT PRIMARY KEY AUTO_INCREMENT,
  Restaurant_ID  INT,
  Name           VARCHAR(100),
  Description    TEXT,
  Price          DECIMAL(8,2),
  FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID)
)
```

#### Order
```sql
Order (
  Order_ID       INT PRIMARY KEY AUTO_INCREMENT,
  Customer_ID    INT,
  Restaurant_ID  INT,
  Order_Date     DATETIME,
  Total_Amount   DECIMAL(10,2),
  FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
  FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID)
)
```

#### Order_Item
```sql
Order_Item (
  OrderItem_ID   INT PRIMARY KEY AUTO_INCREMENT,
  Order_ID       INT,
  Item_ID        INT,
  Quantity       INT,
  Subtotal       DECIMAL(10,2),
  FOREIGN KEY (Order_ID) REFERENCES Order(Order_ID),
  FOREIGN KEY (Item_ID) REFERENCES Menu_Item(Item_ID)
)
```

#### Delivery
```sql
Delivery (
  Delivery_ID    INT PRIMARY KEY AUTO_INCREMENT,
  Order_ID       INT,
  Delivery_Date  DATETIME,
  Delivery_Status VARCHAR(50),
  FOREIGN KEY (Order_ID) REFERENCES Order(Order_ID)
)
```