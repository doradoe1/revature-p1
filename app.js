const express = require('express');
const multer = require('multer');
const ejs = require('ejs');
const path = require('path');
const Sequelize = require('sequelize');

//Set the storage engine for Multer:
const storage = multer.diskStorage({
    destination: './public/uploads/',
    filename: function (req, file, cb) {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
});

//Initialize the upload:
const upload = multer({
    storage: storage,
    fileFilter: function (req, file, cb) {
        checkfiletype(file, cb);
    }
}).single('myimage');

//Function to check the file type:
function checkfiletype(file, cb) {
    const filetypes = /jpeg|jpg|png|gif/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);

    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb('Images only please!!');
    }
}

//Initialize the app:
const app = express();

//Get ejs going:
app.set('view engine', 'ejs');

//Create a public folder for future images:
app.use(express.static('./public'));

app.get('/', (req, res) => res.render('index'));
app.post('/upload', (req, res) => {
    upload(req, res, (err) => {
        if (err) {
            res.render('index', {
                msg: err
            });
        } else {
            if (req.file == undefined) {
                res.render('index', {
                    msg: 'Please select a file before submitting!'
                });
            } else {
                res.render('index', {
                    msg: 'File uploaded!',
                    file: `uploads/${req.file.filename}`
                });
            }
        }
    });
});
const port = 8080;
app.listen(port, () => console.log('Server Towfikul Running and ready to work on port 8080'));