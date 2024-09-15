
import { NextRequest, NextResponse } from "next/server";
import { getTodos, addTodo } from "../../../data/store";

export async function GET(request: NextRequest) {
  const todos = getTodos();
  console.log("request: ",request);
  return NextResponse.json(todos);
}

export async function POST(request: NextRequest) {
  console.log("request: ",request);
  try {
    const { title } = await request.json();
    if (!title) {
      return NextResponse.json({ error: "Title is required" }, { status: 400 });
    }
    const newTodo = addTodo(title);
    return NextResponse.json(newTodo, { status: 201 });
  } catch (error) {
    console.error(error);
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
  }
}

