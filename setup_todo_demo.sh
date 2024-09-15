#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to create directories if they don't exist
create_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory: $1"
  else
    echo "Directory already exists: $1"
  fi
}

# Function to create files with content using here-documents
create_file() {
  local path="$1"
  shift
  echo "Creating file: $path"
  cat << EOF > "$path"
$1
EOF
}

# Step 1: Install Required Dependencies
echo "Installing dependencies: swr and uuid"
npm install swr uuid

# Step 2: Creating the Data Layer
create_dir "src/data"

create_file "src/data/store.ts" '
import { v4 as uuidv4 } from "uuid";

export interface Todo {
  id: string;
  title: string;
  completed: boolean;
  createdAt: string;
}

let todos: Todo[] = []; // In-memory todos array

export function getTodos(): Todo[] {
  return todos;
}

export function addTodo(title: string): Todo {
  const newTodo: Todo = {
    id: uuidv4(),
    title,
    completed: false,
    createdAt: new Date().toISOString(),
  };
  todos.push(newTodo);
  return newTodo;
}

export function updateTodo(id: string, updatedFields: Partial<Omit<Todo, "id" | "createdAt">>): Todo | undefined {
  const todo = todos.find((t) => t.id === id);
  if (todo) {
    Object.assign(todo, updatedFields);
  }
  return todo;
}

export function deleteTodo(id: string): boolean {
  const index = todos.findIndex((t) => t.id === id);
  if (index !== -1) {
    todos.splice(index, 1);
    return true;
  }
  return false;
}
'

# Step 3: Building the API Routes
create_dir "src/app/api/todos/[id]"

# Create Todos API Route (GET and POST)
create_file "src/app/api/todos/route.ts" '
import { NextRequest, NextResponse } from "next/server";
import { getTodos, addTodo } from "../../../data/store";

export async function GET(request: NextRequest) {
  const todos = getTodos();
  return NextResponse.json(todos);
}

export async function POST(request: NextRequest) {
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
'

# Create Todo Item API Route (PUT and DELETE)
create_file "src/app/api/todos/[id]/route.ts" '
import { NextRequest, NextResponse } from "next/server";
import { updateTodo, deleteTodo } from "../../../../data/store";

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  const { id } = params;
  try {
    const { completed } = await request.json();
    if (typeof completed !== "boolean") {
      return NextResponse.json({ error: "Completed status must be a boolean" }, { status: 400 });
    }
    const updatedTodo = updateTodo(id, { completed });
    if (!updatedTodo) {
      return NextResponse.json({ error: "Todo not found" }, { status: 404 });
    }
    return NextResponse.json(updatedTodo, { status: 200 });
  } catch (error) {
    console.error(error);
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  const { id } = params;
  try {
    const success = deleteTodo(id);
    if (!success) {
      return NextResponse.json({ error: "Todo not found" }, { status: 404 });
    }
    return NextResponse.json({ message: "Todo deleted successfully" }, { status: 200 });
  } catch (error) {
    console.error(error);
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
  }
}
'

# Step 4: Creating Frontend Components
create_dir "src/hooks"

create_file "src/hooks/useTodos.ts" '
import useSWR from "swr";

export interface Todo {
  id: string;
  title: string;
  completed: boolean;
  createdAt: string;
}

const fetcher = (url: string) => fetch(url).then((res) => res.json());

export default function useTodos() {
  const { data, error, mutate } = useSWR<Todo[]>("/api/todos", fetcher);

  return {
    todos: data,
    isLoading: !error && !data,
    isError: error,
    mutate,
  };
}
'

create_dir "src/components"

# Create TodoList Component
create_file "src/components/TodoList.tsx" '
"use client";

import React from "react";
import useTodos, { Todo } from "../hooks/useTodos";
import TodoItem from "./TodoItem";

const TodoList: React.FC = () => {
  const { todos, isLoading, isError } = useTodos();

  if (isLoading) return <div>Loading todos...</div>;
  if (isError) return <div>Failed to load todos.</div>;

  return (
    <div>
      {todos && todos.length === 0 && <p>No todos yet. Add one below!</p>}
      {todos?.map((todo: Todo) => (
        <TodoItem key={todo.id} todo={todo} />
      ))}
    </div>
  );
};

export default TodoList;
'

# Create TodoItem Component
create_file "src/components/TodoItem.tsx" '
"use client";

import React, { useState } from "react";
import useTodos, { Todo } from "../hooks/useTodos";

interface TodoItemProps {
  todo: Todo;
}

const TodoItem: React.FC<TodoItemProps> = ({ todo }) => {
  const { mutate } = useTodos();
  const [isUpdating, setIsUpdating] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  const toggleCompleted = async () => {
    setIsUpdating(true);
    try {
      const res = await fetch(`/api/todos/${todo.id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ completed: !todo.completed }),
      });

      if (!res.ok) {
        throw new Error("Failed to update todo");
      }

      mutate();
    } catch (error) {
      console.error(error);
      alert("Failed to update todo");
    } finally {
      setIsUpdating(false);
    }
  };

  const deleteTodo = async () => {
    if (!confirm("Are you sure you want to delete this todo?")) return;
    setIsDeleting(true);
    try {
      const res = await fetch(`/api/todos/${todo.id}`, {
        method: "DELETE",
      });

      if (!res.ok) {
        throw new Error("Failed to delete todo");
      }

      mutate();
    } catch (error) {
      console.error(error);
      alert("Failed to delete todo");
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <div style={styles.todoContainer}>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={toggleCompleted}
        disabled={isUpdating}
      />
      <span style={{ ...styles.todoTitle, textDecoration: todo.completed ? "line-through" : "none" }}>
        {todo.title}
      </span>
      <button onClick={deleteTodo} disabled={isDeleting} style={styles.deleteButton}>
        {isDeleting ? "Deleting..." : "Delete"}
      </button>
    </div>
  );
};

const styles = {
  todoContainer: {
    display: "flex",
    alignItems: "center",
    marginBottom: "0.5rem",
  },
  todoTitle: {
    flex: 1,
    marginLeft: "0.5rem",
  },
  deleteButton: {
    marginLeft: "0.5rem",
    padding: "0.3rem 0.6rem",
    backgroundColor: "#ff4d4f",
    color: "white",
    border: "none",
    borderRadius: "3px",
    cursor: "pointer",
  },
};

export default TodoItem;
'

# Create NewTodoForm Component
create_file "src/components/NewTodoForm.tsx" '
"use client";

import React, { useState } from "react";
import useTodos from "../hooks/useTodos";

const NewTodoForm: React.FC = () => {
  const { mutate } = useTodos();
  const [title, setTitle] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;

    setIsSubmitting(true);
    try {
      const res = await fetch("/api/todos", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ title }),
      });

      if (!res.ok) {
        throw new Error("Failed to add todo");
      }

      setTitle("");
      mutate();
    } catch (error) {
      console.error(error);
      alert("Failed to add todo");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={styles.form}>
      <input
        type="text"
        placeholder="Enter new todo"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        style={styles.input}
      />
      <button type="submit" disabled={isSubmitting} style={styles.button}>
        {isSubmitting ? "Adding..." : "Add Todo"}
      </button>
    </form>
  );
};

const styles = {
  form: {
    display: "flex",
    marginBottom: "1rem",
  },
  input: {
    flex: 1,
    padding: "0.5rem",
    marginRight: "0.5rem",
    border: "1px solid #ccc",
    borderRadius: "3px",
  },
  button: {
    padding: "0.5rem 1rem",
    border: "none",
    borderRadius: "3px",
    backgroundColor: "#1890ff",
    color: "white",
    cursor: "pointer",
  },
};

export default NewTodoForm;
'

# Step 5: Assemble the Main Page
create_file "src/app/page.tsx" '
"use client";

import Head from "next/head";
import NewTodoForm from "../components/NewTodoForm";
import TodoList from "../components/TodoList";

const Home: React.FC = () => {
  return (
    <div style={styles.container}>
      <Head>
        <title>Next.js TODO List Demo</title>
        <meta name="description" content="A simple Next.js demo for a TODO list." />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main style={styles.main}>
        <h1>TODO List</h1>
        <NewTodoForm />
        <TodoList />
      </main>
    </div>
  );
};

const styles = {
  container: {
    padding: "2rem",
    fontFamily: "Arial, sans-serif",
  },
  main: {
    maxWidth: "600px",
    margin: "0 auto",
  },
};

export default Home;
'

echo "Setup complete! You can now start your Next.js development server with 'npm run dev'. Navigate to http://localhost:3000 in your browser to see the TODO list demo."
