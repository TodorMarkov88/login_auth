const express = require("express");
const bcryptjs = require("bcryptjs");
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth");
const authRouter = express.Router();
require('dotenv').config()
const mysql = require('mysql2/promise');
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
  connectionLimit: 10
});

// Sign Up
authRouter.post("/api/signup", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Check if the email already exists
    const [rows] = await pool.execute("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    
    if (rows.length > 0) {
      return res.status(400).json({ error: "User with same email already exists!" });
    }

    // Hash the password
    const hashedPassword = bcryptjs.hashSync(password, 8);

    // Insert the user into the database
    const [result] = await pool.execute(
      "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
      [name, email, hashedPassword]
    );

    // Generate a JWT token
    const token = jwt.sign({ id: result.insertId }, process.env.JWT_SECRET);

    res.json({ token, name, email });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
});

// Sign In
authRouter.post("/api/signing", async (req, res) => {
  const { email, password } = req.body;

  try {
    // Find the user with the given email
    const [rows] = await pool.execute("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    const user = rows[0];
 
    // If user doesn't exist or password doesn't match, return error response
    if (!user || !bcryptjs.compareSync(password, user.password)) {
      return res.status(400).json({ msg: "Invalid email or password" });
    }

    // Generate a JWT token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET);

    // Return success response with token and user details
    res.json({ token, name: user.name, email });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});



// Verify token
authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");

    if (!token) {
      return res.json(false);
    }

    // Verify the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Find the user with the given ID
    const [rows] = await pool.execute("SELECT * FROM users WHERE id = ?", [
      decoded.id,
    ]);
    const user = rows[0];

    if (!user) {
      return res.json(false);
    }

    res.json(true);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Server error" });
  }
});
 
// Get user data
authRouter.get("/", auth, async (req, res) => {
  try {
    const { id } = req.user;
    const [rows, fields] = await req.app.locals.pool.execute(
      "SELECT id, name, email FROM users WHERE id = ?",
      [id]
    );
    res.json(rows[0]);
    console.log( res.json(rows[0]))
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
module.exports = authRouter;
