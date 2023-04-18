var express = require('express');
 
const PORT= 3000
const app=express()
const mysql = require("mysql2/promise");
 
const authRouter = require("./routes/auth");
require('dotenv').config()

app.use(express.json())
app.use(authRouter);


const DB = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});
 
app.use((req, res, next) => {
  req.DB = DB;
  next();
});
(async () => {
    try {
      const connection = await DB.getConnection();

      console.log('MySQL database connected successfully!');
      connection.release();
  
    } catch (error) {
      console.error(`Error connecting to MySQL database: ${error.message}`);
    }
  })();


app.listen(PORT,'192.168.0.104',()=>{
    console.log(`conected at PORT: ${PORT}`)
})

