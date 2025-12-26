from fastapi import FastAPI

app=FastAPI()
@app.get("/")
async def hello():
   return {"messag":"this is cicd"}

@app.get("/shahryar")
async def shahryar():
   return {"this is greate":"thinker "}   