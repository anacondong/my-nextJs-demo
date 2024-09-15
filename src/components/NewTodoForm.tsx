
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

