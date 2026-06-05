import { title, prose } from "@/components/primitives";

export default function PricingPage() {
  return (
    <div>
      <h1 className={title()}>Pricing</h1>
      <p className={`${prose()} mt-6 max-w-xl`}>
        Nothing for sale here — this page is a placeholder.
      </p>
    </div>
  );
}
