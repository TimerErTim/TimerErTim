import { AppLink, Card, Divider } from "@/components/ui";
import { routes } from "@/paths";
import { contact } from "@/site/contact";

function telHref(phone: string): string {
  return `tel:${phone.replace(/\s/g, "")}`;
}

export function AboutSidebar() {
  return (
    <Card className="flex h-fit max-h-full flex-col overflow-hidden">
      <h2 className="shrink-0 text-small leading-small font-bold text-foreground m-0 mb-4">
        Contact
      </h2>
      <ul className="m-0 flex flex-col gap-3 p-0 list-none text-small leading-small">
        <li>
          <p className="text-muted m-0">Email</p>
          <AppLink
            external
            href={`mailto:${contact.email}`}
            target="_self"
          >
            {contact.email}
          </AppLink>
        </li>
        <li>
          <p className="text-muted m-0">Phone</p>
          <AppLink
            external
            href={telHref(contact.phone)}
            target="_self"
          >
            {contact.phone}
          </AppLink>
        </li>
      </ul>

      <Divider className="my-4" />
      <AppLink
        href={routes.cvPdf()}
        variant="bold"
        rel="noopener noreferrer"
        target="_blank"
      >
        Curriculum Vitae (PDF)
      </AppLink>
    </Card>
  );
}
