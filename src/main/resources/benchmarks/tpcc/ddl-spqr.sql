DROP TABLE IF EXISTS history CASCADE;
DROP TABLE IF EXISTS new_order CASCADE;
DROP TABLE IF EXISTS order_line CASCADE;
DROP TABLE IF EXISTS oorder CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS district CASCADE;
DROP TABLE IF EXISTS stock CASCADE;
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS warehouse CASCADE;

CREATE TABLE warehouse (
                           W_ID       int            NOT NULL,
                           W_YTD      decimal(12, 2) NOT NULL,
                           W_TAX      decimal(4, 4)  NOT NULL,
                           W_NAME     varchar(10)    NOT NULL,
                           W_STREET_1 varchar(20)    NOT NULL,
                           W_STREET_2 varchar(20)    NOT NULL,
                           W_CITY     varchar(20)    NOT NULL,
                           W_STATE    char(2)        NOT NULL,
                           W_ZIP      char(9)        NOT NULL,
                           PRIMARY KEY (W_ID)
);

CREATE TABLE item (
                      I_ID    int           NOT NULL,
                      I_NAME  varchar(24)   NOT NULL,
                      I_PRICE decimal(5, 2) NOT NULL,
                      I_DATA  varchar(50)   NOT NULL,
                      I_IM_ID int           NOT NULL,
                      PRIMARY KEY (I_ID)
);

CREATE TABLE stock (
                       S_W_ID       int           NOT NULL,
                       S_I_ID       int           NOT NULL,
                       S_QUANTITY   int           NOT NULL,
                       S_YTD        decimal(8, 2) NOT NULL,
                       S_ORDER_CNT  int           NOT NULL,
                       S_REMOTE_CNT int           NOT NULL,
                       S_DATA       varchar(50)   NOT NULL,
                       S_DIST_01    char(24)      NOT NULL,
                       S_DIST_02    char(24)      NOT NULL,
                       S_DIST_03    char(24)      NOT NULL,
                       S_DIST_04    char(24)      NOT NULL,
                       S_DIST_05    char(24)      NOT NULL,
                       S_DIST_06    char(24)      NOT NULL,
                       S_DIST_07    char(24)      NOT NULL,
                       S_DIST_08    char(24)      NOT NULL,
                       S_DIST_09    char(24)      NOT NULL,
                       S_DIST_10    char(24)      NOT NULL,
                       FOREIGN KEY (S_W_ID) REFERENCES warehouse (W_ID) ON DELETE CASCADE,
                       FOREIGN KEY (S_I_ID) REFERENCES item (I_ID) ON DELETE CASCADE,
                       PRIMARY KEY (S_W_ID, S_I_ID)
);

CREATE TABLE district (
                          D_W_ID      int            NOT NULL,
                          D_ID        int            NOT NULL,
                          D_YTD       decimal(12, 2) NOT NULL,
                          D_TAX       decimal(4, 4)  NOT NULL,
                          D_NEXT_O_ID int            NOT NULL,
                          D_NAME      varchar(10)    NOT NULL,
                          D_STREET_1  varchar(20)    NOT NULL,
                          D_STREET_2  varchar(20)    NOT NULL,
                          D_CITY      varchar(20)    NOT NULL,
                          D_STATE     char(2)        NOT NULL,
                          D_ZIP       char(9)        NOT NULL,
                          FOREIGN KEY (D_W_ID) REFERENCES warehouse (W_ID) ON DELETE CASCADE,
                          PRIMARY KEY (D_W_ID, D_ID)
);

CREATE TABLE customer (
                          C_W_ID         int            NOT NULL,
                          C_D_ID         int            NOT NULL,
                          C_ID           int            NOT NULL,
                          C_DISCOUNT     decimal(4, 4)  NOT NULL,
                          C_CREDIT       char(2)        NOT NULL,
                          C_LAST         varchar(16)    NOT NULL,
                          C_FIRST        varchar(16)    NOT NULL,
                          C_CREDIT_LIM   decimal(12, 2) NOT NULL,
                          C_BALANCE      decimal(12, 2) NOT NULL,
                          C_YTD_PAYMENT  float          NOT NULL,
                          C_PAYMENT_CNT  int            NOT NULL,
                          C_DELIVERY_CNT int            NOT NULL,
                          C_STREET_1     varchar(20)    NOT NULL,
                          C_STREET_2     varchar(20)    NOT NULL,
                          C_CITY         varchar(20)    NOT NULL,
                          C_STATE        char(2)        NOT NULL,
                          C_ZIP          char(9)        NOT NULL,
                          C_PHONE        char(16)       NOT NULL,
                          C_SINCE        timestamp      NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          C_MIDDLE       char(2)        NOT NULL,
                          C_DATA         varchar(500)   NOT NULL,
                          FOREIGN KEY (C_W_ID, C_D_ID) REFERENCES district (D_W_ID, D_ID) ON DELETE CASCADE,
                          PRIMARY KEY (C_W_ID, C_D_ID, C_ID)
);

CREATE TABLE history (
                         H_C_ID   int           NOT NULL,
                         H_C_D_ID int           NOT NULL,
                         H_C_W_ID int           NOT NULL,
                         H_D_ID   int           NOT NULL,
                         H_W_ID   int           NOT NULL,
                         H_DATE   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         H_AMOUNT decimal(6, 2) NOT NULL,
                         H_DATA   varchar(24)   NOT NULL,
                         FOREIGN KEY (H_C_W_ID, H_C_D_ID, H_C_ID) REFERENCES customer (C_W_ID, C_D_ID, C_ID) ON DELETE CASCADE,
                         FOREIGN KEY (H_W_ID, H_D_ID) REFERENCES district (D_W_ID, D_ID) ON DELETE CASCADE
);

CREATE TABLE oorder (
                        O_W_ID       int       NOT NULL,
                        O_D_ID       int       NOT NULL,
                        O_ID         int       NOT NULL,
                        O_C_ID       int       NOT NULL,
                        O_CARRIER_ID int                DEFAULT NULL,
                        O_OL_CNT     int       NOT NULL,
                        O_ALL_LOCAL  int       NOT NULL,
                        O_ENTRY_D    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (O_W_ID, O_D_ID, O_ID),
                        FOREIGN KEY (O_W_ID, O_D_ID, O_C_ID) REFERENCES customer (C_W_ID, C_D_ID, C_ID) ON DELETE CASCADE,
                        UNIQUE (O_W_ID, O_D_ID, O_C_ID, O_ID)
);

CREATE TABLE new_order (
                           NO_W_ID int NOT NULL,
                           NO_D_ID int NOT NULL,
                           NO_O_ID int NOT NULL,
                           FOREIGN KEY (NO_W_ID, NO_D_ID, NO_O_ID) REFERENCES oorder (O_W_ID, O_D_ID, O_ID) ON DELETE CASCADE,
                           PRIMARY KEY (NO_W_ID, NO_D_ID, NO_O_ID)
);

CREATE TABLE order_line (
                            OL_W_ID        int           NOT NULL,
                            OL_D_ID        int           NOT NULL,
                            OL_O_ID        int           NOT NULL,
                            OL_NUMBER      int           NOT NULL,
                            OL_I_ID        int           NOT NULL,
                            OL_DELIVERY_D  timestamp     NULL DEFAULT NULL,
                            OL_AMOUNT      decimal(6, 2) NOT NULL,
                            OL_SUPPLY_W_ID int           NOT NULL,
                            OL_QUANTITY    decimal(6, 2) NOT NULL,
                            OL_DIST_INFO   char(24)      NOT NULL,
                            FOREIGN KEY (OL_W_ID, OL_D_ID, OL_O_ID) REFERENCES oorder (O_W_ID, O_D_ID, O_ID) ON DELETE CASCADE,
                            FOREIGN KEY (OL_SUPPLY_W_ID, OL_I_ID) REFERENCES stock (S_W_ID, S_I_ID) ON DELETE CASCADE,
                            PRIMARY KEY (OL_W_ID, OL_D_ID, OL_O_ID, OL_NUMBER)
);

CREATE INDEX idx_item on item (I_ID);

CREATE INDEX idx_warehouse on warehouse (W_ID);

CREATE INDEX idx_district_name ON district (D_W_ID, D_ID);

CREATE INDEX idx_customer_name ON customer (C_W_ID, C_D_ID, C_LAST, C_FIRST);

CREATE INDEX idx_oorder_name ON oorder (O_W_ID,O_D_ID,O_ID);

CREATE INDEX fkey_stock_2_name ON stock (S_W_ID, S_I_ID);

CREATE INDEX fkey_new_order_1_name ON new_order (NO_W_ID, NO_D_ID);

CREATE INDEX fkey_new_order_2_name ON new_order (NO_W_ID, NO_D_ID, NO_O_ID);

CREATE INDEX fkey_order_line_2_name ON order_line (OL_W_ID, OL_D_ID, OL_O_ID);

CREATE INDEX fkey_history_1_name ON history (H_C_W_ID,H_C_D_ID,H_C_ID);

CREATE INDEX fkey_history_2_name ON history (H_W_ID,H_D_ID);