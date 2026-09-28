CREATE TABLE market_data(
trade_date DATE,
symbol VARCHAR(10),
open_price NUMERIC,
high_price NUMERIC,
low_price NUMERIC,
close_price NUMERIC,
volume BIGINT,
PRIMARY KEY (trade_date, symbol)
);




SELECT * FROM market_data
ORDER BY trade_date DESC
LIMIT 10;


SELECT 
    trade_date,
    symbol,
    close_price,
    
    -- 1. Trend Analysis: 7-Day Simple Moving Average (SMA)
    ROUND(AVG(close_price) OVER (
        PARTITION BY symbol 
        ORDER BY trade_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS sma_7_day,
    
    -- 2. Risk Analysis: Intraday Volatility Percentage
    ROUND(((high_price - low_price) / low_price) * 100, 2) AS intraday_vol_pct,
    
    -- 3. Momentum: Day-over-Day (DoD) Return Percentage
    ROUND(((close_price - LAG(close_price) OVER (
        PARTITION BY symbol 
        ORDER BY trade_date
    )) / LAG(close_price) OVER (
        PARTITION BY symbol 
        ORDER BY trade_date
    )) * 100, 2) AS dod_return_pct

FROM market_data
WHERE symbol = 'HDB'
ORDER BY trade_date DESC
LIMIT 15;