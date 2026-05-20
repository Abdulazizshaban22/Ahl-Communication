import express from 'express';
import pkg from 'pg';
const { Pool } = pkg;

const app = express();
app.use(express.json());
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function ensure() {
  await pool.query(`create table if not exists tasks(
    id serial primary key,
    title text not null,
    status text not null default 'todo',
    created_at timestamptz default now()
  )`);
}
ensure();

app.get('/health', (_,res)=>res.json({ok:true, service:'business-api'}));

app.get('/tasks', async (_,res)=>{
  const { rows } = await pool.query('select * from tasks order by id desc');
  res.json(rows);
});

app.post('/tasks', async (req,res)=>{
  const { title } = req.body || {};
  if(!title) return res.status(400).json({error:'title required'});
  const { rows } = await pool.query('insert into tasks(title) values($1) returning *', [title]);
  res.status(201).json(rows[0]);
});

app.patch('/tasks/:id', async (req,res)=>{
  const id = req.params.id;
  const { status } = req.body || {};
  const { rows } = await pool.query('update tasks set status=$1 where id=$2 returning *', [status||'todo', id]);
  res.json(rows[0]);
});

app.listen(3003, ()=>console.log('business-api:3003'));
