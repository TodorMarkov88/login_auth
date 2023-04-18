// const jwt = require("jsonwebtoken");

// const auth = async (req, res, next) => {
//   try {
//     const token = req.header("x-auth-token");
//     if (!token  )
//       return res.status(401).json({ msg: "No auth token, access denied" });

//     const verified = jwt.verify(token, "passwordKey");
//     if (!verified)
//       return res
//         .status(401)
//         .json({ msg: "Token verification failed, authorization denied." });

//     req.user = verified.id;
//     req.token = token;
//     next();
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };

// module.exports = auth;

const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');

require('dotenv').config()
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
  connectionLimit: 10
});

const auth = async (req, res, next) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) {
      return res.status(401).json({ msg: 'No auth token, access denied' });
    }

    const decoded = jwt.verify(token, 'cat');
    const [rows, fields] = await pool.execute(
      'SELECT * FROM users WHERE id = ?',
      [decoded.id]
    );

    if (!rows.length) {
      return res
        .status(401)
        .json({ msg: 'Token verification failed, authorization denied.' });
    }

    req.user = rows[0];
    req.token = token;
    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = auth;
