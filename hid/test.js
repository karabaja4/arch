const fs = require('fs');

const NULL_CHAR = String.fromCharCode(0);

function writeReport(report) {
    fs.open('/dev/hidg0', 'r+', (err, fd) => {
        if (err) {
            console.error("Error opening device file:", err);
            return;
        }
        
        fs.write(fd, report, (err) => {
            if (err) {
                console.error("Error writing to device file:", err);
            }
            fs.close(fd, (err) => {
                if (err) {
                    console.error("Error closing device file:", err);
                }
            });
        });
    });
}

// Press a
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(4) + NULL_CHAR.repeat(5));

// Release keys
writeReport(NULL_CHAR.repeat(8));

// Press SHIFT + a = A
writeReport(String.fromCharCode(32) + NULL_CHAR + String.fromCharCode(4) + NULL_CHAR.repeat(5));

// Press b
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(5) + NULL_CHAR.repeat(5));

// Release keys
writeReport(NULL_CHAR.repeat(8));

// Press SHIFT + b = B
writeReport(String.fromCharCode(32) + NULL_CHAR + String.fromCharCode(5) + NULL_CHAR.repeat(5));

// Press SPACE key
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(44) + NULL_CHAR.repeat(5));

// Press c key
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(6) + NULL_CHAR.repeat(5));

// Press d key
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(7) + NULL_CHAR.repeat(5));

// Press RETURN/ENTER key
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(40) + NULL_CHAR.repeat(5));

// Press e key
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(8) + NULL_CHAR.repeat(5));

// Press f key
writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(9) + NULL_CHAR.repeat(5));

writeReport(NULL_CHAR.repeat(2) + String.fromCharCode(49) + NULL_CHAR.repeat(5));

// Release all keys
writeReport(NULL_CHAR.repeat(8));
