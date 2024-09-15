"use client";

import Head from "next/head";
import NewTodoForm from "../components/NewTodoForm";
import TodoList from "../components/TodoList";

const Home: React.FC = () => {
  return (
    <div style={styles.container}>
      <Head>
        <title>Next.js TODO List Demo</title>
        <meta
          name="description"
          content="A simple Next.js demo for a TODO list."
        />
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
