import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'CONNECTA — Modern Social Network',
  description: 'Connecta is an original full-stack social networking platform.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" data-theme="light">
      <body>{children}</body>
    </html>
  );
}
