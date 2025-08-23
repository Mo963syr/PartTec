
export default function App() {
  return (
    <div dir="rtl" className="min-h-screen grid place-items-center">
      <div className="text-center space-y-3">
        <h1 className="text-3xl font-bold">PartTec</h1>
        <p className="text-slate-600">مرحبًا! انتقل إلى لوحة التحكم من خلال /admin</p>
        <a className="btn btn-primary" href="/admin">اذهب إلى لوحة التحكم</a>
      </div>
    </div>
  )
}
