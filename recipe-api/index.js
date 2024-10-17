const express = require('express');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const app = express();

// Middleware to parse JSON requests
app.use(bodyParser.json());

const SECRET_KEY = 'your_secret_key'; // Replace with your own secret key

// In-memory user storage for demo (can be replaced by database)
const users = [
    { username: 'admin', password: bcrypt.hashSync('admin123', 8), isAdmin: true },
    { username: 'user', password: bcrypt.hashSync('user123', 8), isAdmin: false }
];

// In-memory storage for recipes (can be replaced by a database)
const recipes = [];

// JWT Authentication Middleware
function authenticateJWT(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(403).send({ message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1]; // Extract token from "Bearer <token>"

    jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) {
            return res.status(401).send({ message: 'Unauthorized' });
        }

        req.user = user; // Attach user info to the request object
        next();
    });
}

// 1. Login route (POST /auth/login) to get a JWT token
app.post('/auth/login', (req, res) => {
    const { username, password } = req.body;

    // Find the user by username
    const user = users.find(u => u.username === username);

    if (!user) {
        return res.status(404).send({ message: 'User not found' });
    }

    // Compare the hashed password
    const passwordIsValid = bcrypt.compareSync(password, user.password);
    if (!passwordIsValid) {
        return res.status(401).send({ message: 'Invalid password' });
    }

    // Generate JWT token
    const token = jwt.sign({ username: user.username, isAdmin: user.isAdmin }, SECRET_KEY, { expiresIn: '1h' });

    // Send back the token
    res.status(200).send({ token });
});

// 2. Add a new recipe (Protected route: POST /recipes)
app.post('/recipes', authenticateJWT, (req, res) => {
    const { title, type, imagePath, ingredients, steps } = req.body;

    // Validate request body fields
    if (!title || !type || !imagePath || !ingredients || !steps) {
        return res.status(400).send({ message: 'Please provide all required fields' });
    }

    // Create a new recipe object
    const newRecipe = {
        title,
        type,
        imagePath,
        ingredients,
        steps,
        createdBy: req.user.username // Associate the recipe with the user who created it
    };

    // Save the recipe in the in-memory storage
    recipes.push(newRecipe);

    // Send success response
    res.status(201).send({ message: 'Recipe added successfully', recipe: newRecipe });
});

// 3. Get all recipes (Protected route: GET /recipes)
app.get('/recipes', authenticateJWT, (req, res) => {
    res.json(recipes);
});

// Start the server on port 5000
const PORT = 5001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
