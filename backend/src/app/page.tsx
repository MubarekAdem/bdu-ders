"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    // Redirect to admin login page
    router.push("/admin-login");
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-2xl font-bold text-gray-900 mb-4">
          ደርስ BDU Admin Panel
        </h1>
        <p className="text-gray-600">Redirecting to admin login...</p>
      </div>
    </div>
  );
}
