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
      <span
        style={{
          ...styles.todoTitle,
          textDecoration: todo.completed ? "line-through" : "none",
        }}
      >
        {todo.title}
      </span>
      <button
        onClick={deleteTodo}
        disabled={isDeleting}
        style={styles.deleteButton}
      >
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
