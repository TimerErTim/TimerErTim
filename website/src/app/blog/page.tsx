import { title } from "@/components/primitives";
import { getAllServerBlogMetadata } from "@/model/blogs";
import Link from "next/link";

export default async function BlogPage() {
  const blogs = await getAllServerBlogMetadata();

  return (
    <div>
      <h1 className={title()}>Blog</h1>
      <div style={{display: 'flex', flexDirection: 'column', gap: '2rem', marginTop: '2rem'}}>
        {blogs.map((blog) => (
          <div key={blog.slug} style={{padding: '1rem', border: '1px solid #eee', borderRadius: '8px'}}>
            <Link href={`/blog/${blog.slug}`} style={{textDecoration: 'none', color: 'inherit'}}>
              <h2 style={{margin: '0 0 0.25em 0'}}>{blog.title}</h2>
            </Link>
            <div style={{marginBottom: '0.5em', fontSize: '0.97em', color: '#555'}}>
              {blog.description}
            </div>
            <div style={{fontSize: '0.9em', color: '#888'}}>
              Last updated: {blog.updatedAt.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
