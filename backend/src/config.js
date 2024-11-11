import {config} from 'dotenv';

config();

export default {
    "port": process.env.PORT || 3000,
    "server": process.env.DBserver || '',
    "user": process.env.DBuser || '',
    "password": process.env.DBpassword || '',
    "database": process.env.DBdatabase || ''
}