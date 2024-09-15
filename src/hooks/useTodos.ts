
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

