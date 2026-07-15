import { createFileRoute } from '@tanstack/react-router'
import { LogOut } from 'lucide-react'
import { useState } from 'react'

import { Button } from '@/components/ui/button'
import { authClient } from '@/lib/auth-client'

export const Route = createFileRoute('/')({ component: App })

function App() {
  const { data: session, error, isPending } = authClient.useSession()
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [actionError, setActionError] = useState<string | null>(null)

  const signIn = async () => {
    setIsSubmitting(true)
    setActionError(null)

    const result = await authClient.signIn.social({
      provider: 'discord',
      callbackURL: window.location.origin,
      errorCallbackURL: window.location.origin,
    })

    if (result.error) {
      setActionError(result.error.message ?? 'Discord sign-in failed.')
      setIsSubmitting(false)
    }
  }

  const signOut = async () => {
    setIsSubmitting(true)
    setActionError(null)

    const result = await authClient.signOut()
    if (result.error) {
      setActionError(result.error.message ?? 'Sign-out failed.')
    }

    setIsSubmitting(false)
  }

  return (
    <main className="relative grid min-h-svh place-items-center overflow-hidden bg-[#0d0f15] px-6 py-12 text-white">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,#5865f233,transparent_42%),radial-gradient(circle_at_bottom_right,#8b5cf622,transparent_36%)]" />

      <section className="relative w-full max-w-md overflow-hidden rounded-3xl border border-white/10 bg-[#171922]/90 p-8 shadow-2xl shadow-black/40 backdrop-blur-xl sm:p-10">
        <div className="mb-8 flex items-center gap-3">
          <div className="grid size-11 place-items-center rounded-2xl bg-[#5865f2] shadow-lg shadow-[#5865f2]/20">
            <DiscordIcon className="size-6" />
          </div>
          <div>
            <p className="text-lg font-semibold tracking-tight">HappinessMP</p>
            <p className="text-sm text-white/45">Community account</p>
          </div>
        </div>

        {isPending ? (
          <div
            className="flex min-h-56 items-center justify-center"
            role="status"
          >
            <span className="size-6 animate-spin rounded-full border-2 border-white/15 border-t-[#7c87ff]" />
            <span className="sr-only">Loading session</span>
          </div>
        ) : session ? (
          <div className="space-y-8">
            <div>
              <p className="mb-2 text-sm font-medium text-emerald-400">
                Signed in
              </p>
              <h1 className="text-3xl font-semibold tracking-tight">
                Welcome back.
              </h1>
              <p className="mt-3 text-sm leading-6 text-white/55">
                Your Discord account is connected and ready to use.
              </p>
            </div>

            <div className="flex items-center gap-4 rounded-2xl border border-white/8 bg-white/5 p-4">
              {session.user.image ? (
                <img
                  src={session.user.image}
                  alt=""
                  className="size-12 rounded-full object-cover ring-2 ring-white/10"
                />
              ) : (
                <div className="grid size-12 place-items-center rounded-full bg-[#5865f2] text-lg font-semibold">
                  {session.user.name.charAt(0).toUpperCase()}
                </div>
              )}
              <div className="min-w-0">
                <p className="truncate font-medium">{session.user.name}</p>
                <p className="truncate text-sm text-white/45">
                  {session.user.email}
                </p>
              </div>
            </div>

            <Button
              type="button"
              variant="outline"
              size="lg"
              className="h-11 w-full border-white/10 bg-white/5 text-white hover:bg-white/10 hover:text-white"
              disabled={isSubmitting}
              onClick={signOut}
            >
              <LogOut data-icon="inline-start" />
              {isSubmitting ? 'Signing out…' : 'Sign out'}
            </Button>
          </div>
        ) : (
          <div className="space-y-8">
            <div>
              <p className="mb-2 text-sm font-medium text-[#8e98ff]">Welcome</p>
              <h1 className="text-3xl font-semibold tracking-tight">
                Join the server.
              </h1>
              <p className="mt-3 text-sm leading-6 text-white/55">
                Sign in with Discord to access your HappinessMP account.
              </p>
            </div>

            <Button
              type="button"
              size="lg"
              className="h-12 w-full bg-[#5865f2] text-base text-white shadow-lg shadow-[#5865f2]/20 hover:bg-[#6873f5]"
              disabled={isSubmitting}
              onClick={signIn}
            >
              <DiscordIcon data-icon="inline-start" />
              {isSubmitting ? 'Opening Discord…' : 'Continue with Discord'}
            </Button>
          </div>
        )}

        {(actionError ?? error?.message) && (
          <p
            className="mt-5 rounded-xl border border-red-400/15 bg-red-400/10 px-4 py-3 text-sm text-red-200"
            role="alert"
          >
            {actionError ?? error?.message}
          </p>
        )}
      </section>
    </main>
  )
}

function DiscordIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" {...props}>
      <path d="M19.3 5.34A16.3 16.3 0 0 0 15.22 4l-.5 1.02a15.15 15.15 0 0 0-5.42 0L8.78 4A16.45 16.45 0 0 0 4.7 5.35C2.12 9.16 1.42 12.88 1.77 16.54a16.5 16.5 0 0 0 5 2.53l1.22-1.67a10.5 10.5 0 0 1-1.91-.92l.47-.36c3.68 1.71 7.68 1.71 11.31 0l.48.36c-.61.36-1.26.67-1.92.92l1.22 1.67a16.42 16.42 0 0 0 5-2.53c.41-4.24-.7-7.93-3.34-11.2ZM8.83 14.3c-1.1 0-2.01-1.02-2.01-2.27s.89-2.28 2.01-2.28c1.13 0 2.03 1.03 2.01 2.28 0 1.25-.89 2.27-2.01 2.27Zm6.35 0c-1.1 0-2.01-1.02-2.01-2.27s.89-2.28 2.01-2.28c1.13 0 2.03 1.03 2.01 2.28 0 1.25-.88 2.27-2.01 2.27Z" />
    </svg>
  )
}
