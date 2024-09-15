
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

