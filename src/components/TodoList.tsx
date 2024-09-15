
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

