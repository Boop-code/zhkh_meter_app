const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const HOST = '0.0.0.0';

const dataPath = path.join(__dirname, 'data', 'meters.json');

const server = http.createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    if (req.method === 'GET' && req.url === '/api/meters') {
        try {
            const fileContent = fs.readFileSync(dataPath, 'utf8');
            const data = JSON.parse(fileContent);

            res.writeHead(200);
            res.end(JSON.stringify({
                success: true,
                message: 'Начальные данные получены успешно',
                meters: data.meters
            }));
        } catch (error) {
            console.error('Ошибка чтения данных:', error);

            res.writeHead(500);
            res.end(JSON.stringify({
                success: false,
                message: 'Ошибка получения данных'
            }));
        }

        return;
    }

    res.writeHead(404);
    res.end(JSON.stringify({
        success: false,
        message: 'Маршрут не найден'
    }));
});

server.listen(PORT, HOST, () => {
    console.log('====================================');
    console.log(' REST API ЖКХ запущен');
    console.log(` Адрес: http://172.20.10.2:${PORT}`);
    console.log(` API: http://172.20.10.2:${PORT}/api/meters`);
    console.log('====================================');
});