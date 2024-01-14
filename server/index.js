const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");

require('dotenv').config()

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use(authRouter);

mongoose.connect(process.env.MONGO_URL).then(()=>{
    console.log("MongoDB Connected");
}).catch((e)=>{
    console.error(e);
});

app.listen(PORT,"0.0.0.0",()=>{
    console.log(`Server is running on port ${PORT}`);
});