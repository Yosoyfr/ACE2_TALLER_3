const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

// Config
const PORT = 3000;

// Express App
const app = express();

/**
 * Middlewares
 * CORS
 * MORGAN
 * EXPRESS.JSON
 * EXPRESS.URLENCONDED
 */
app.use(cors({ origin: true, optionsSuccessStatus: 200 }));
app.use(morgan("dev"));
app.use(express.json({ extended: true }));
app.use(express.urlencoded({ extended: true }));

/**
 * Routes
 */
app.get("/", (req, res) => {
	return res.json({ message: "Servidor levantado" });
});

app.listen(PORT, () => console.log(`App listening on port ${PORT}!`));
