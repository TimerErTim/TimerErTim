import { title } from "@/components/primitives";
import { getBlogs } from "@/model/blogs";

export default async function BlogPage() {
  const blogs = await getBlogs();

  return (
    <div>
      <h1 className={title()}>Blog</h1>
      <ul>
        {blogs.map((blog) => (
          <li key={blog.slug}>
            <a href={`/blog/${blog.slug}`}>{blog.title}</a>
          </li>
        ))}
      </ul>
    </div>
  );
}
