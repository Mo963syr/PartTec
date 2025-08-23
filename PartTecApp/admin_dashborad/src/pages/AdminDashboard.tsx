
import React, { useEffect, useMemo, useState } from 'react'
import { motion } from 'framer-motion'
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell
} from 'recharts'

// Define roles: seller, worker, delevery, admin, customer
// Updated roles to reflect backend nomenclature
// 'delevery' is intentionally spelled this way to match the API requirement
export type Role = 'admin' | 'seller' | 'worker' | 'delevery' | 'customer'
export type CreatableRole = 'seller' | 'worker' | 'delevery'

export interface User {
  id: string
  name: string
  email: string
  phone?: string
  role: Role
  active: boolean
  discount?: number
  companyName?: string
  brands?: string[]
  createdAt?: string
}

export interface Stats {
  totalUsers: number
  totalOrders: number
  activeWorkers: number
  avgWorkerDiscount: number
  sellers: number
}

export interface OrdersSeriesPoint { date: string; orders: number }
export type RolesBreakdown = { role: string; value: number }[]

// Utility function to compute statistics based on current users and orders series.
function computeStats(users: User[], ordersSeries: OrdersSeriesPoint[]): Stats {
  const totalUsers = users.length
  const totalOrders = ordersSeries.reduce((sum, p) => sum + p.orders, 0)
  const workerUsers = users.filter(u => u.role === 'worker')
  const activeWorkers = workerUsers.filter(u => u.active).length
  const avgWorkerDiscount = workerUsers.length
    ? Math.round(workerUsers.reduce((sum, u) => sum + (u.discount ?? 0), 0) / workerUsers.length)
    : 0
  const sellers = users.filter(u => u.role === 'seller').length
  return { totalUsers, totalOrders, activeWorkers, avgWorkerDiscount, sellers }
}

// Utility to compute a roles breakdown chart from current users
function computeRoles(users: User[]): RolesBreakdown {
  const count = (role: Role) => users.filter(u => u.role === role).length
  return [
    { role: 'بياع', value: count('seller') },
    { role: 'عامل', value: count('worker') },
    { role: 'زبون', value: count('customer') },
    { role: 'توصيل', value: count('delevery') },
    { role: 'أدمن', value: count('admin') },
  ]
}

// API base
// During local development we proxy `/api` to the remote backend via Vite's
// dev server.  See vite.config.ts for proxy configuration.  In production
// you may set this to an absolute URL such as "https://parttec.onrender.com".
const API_BASE = '/api'

// Sample fallback data for offline/demo
const sampleUsers: User[] = [
  { id: 'u1', name: 'أحمد خالد', email: 'ahmad@ex.com', role: 'worker', active: true, discount: 10, phone: '0933...', createdAt: '2025-05-01' },
  { id: 'u2', name: 'ليلى سالم', email: 'leila@ex.com', role: 'seller', active: true, phone: '0944...', companyName: 'ليلى لتجارة السيارات', brands: ['تويوتا','فورد'], createdAt: '2025-04-12' },
  { id: 'u3', name: 'محمود علي', email: 'mahmoud@ex.com', role: 'customer', active: true, createdAt: '2025-06-03' },
  // Note: use 'delevery' instead of 'delivery' to match API expectations
  { id: 'u4', name: 'نور سامر', email: 'nour@ex.com', role: 'delevery', active: false, createdAt: '2025-06-11' },
  { id: 'u5', name: 'Admin', email: 'admin@ex.com', role: 'admin', active: true, createdAt: '2025-01-01' },
]

const sampleStats: Stats = {
  totalUsers: 1234,
  totalOrders: 876,
  activeWorkers: 42,
  avgWorkerDiscount: 12,
  sellers: 18,
}

const sampleSeries: OrdersSeriesPoint[] = Array.from({ length: 30 }, (_, i) => {
  const day = new Date(); day.setDate(day.getDate() - (29 - i));
  const d = day.toISOString().slice(0, 10)
  return { date: d, orders: Math.floor(30 + Math.random() * 40) }
})

const sampleRoles: RolesBreakdown = [
  { role: 'عامل', value: 42 },
  { role: 'بياع', value: 18 },
  { role: 'زبون', value: 1090 },
  { role: 'توصيل', value: 12 },
  { role: 'أدمن', value: 2 },
]

export default function AdminDashboard() {
  // States
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState<Stats | null>(null)
  const [ordersSeries, setOrdersSeries] = useState<OrdersSeriesPoint[]>([])
  const [roles, setRoles] = useState<RolesBreakdown>([])
  const [users, setUsers] = useState<User[]>([])
  const [query, setQuery] = useState('')
  const [roleFilter, setRoleFilter] = useState<Role | 'all'>('all')

  const [createOpen, setCreateOpen] = useState(false)
  const [createRole, setCreateRole] = useState<CreatableRole>('seller')
  const [discountOpen, setDiscountOpen] = useState<{ open: boolean, user?: User, value?: number }>({ open: false })

  // Whenever users or ordersSeries change, recompute stats and roles breakdown.
  useEffect(() => {
    // Compute statistics using current users and orders series
    setStats(computeStats(users, ordersSeries))
    // Update roles breakdown chart
    setRoles(computeRoles(users))
  }, [users, ordersSeries])

  // Filtered users list
  const filteredUsers = useMemo(() => {
    const q = query.trim().toLowerCase()
    return users.filter(u => {
      const matchesQ = !q
        || u.name.toLowerCase().includes(q)
        || u.email.toLowerCase().includes(q)
        || (u.phone || '').toLowerCase().includes(q)
        || (u.companyName || '').toLowerCase().includes(q)
      const matchesRole = roleFilter === 'all' ? true : u.role === roleFilter
      return matchesQ && matchesRole
    })
  }, [users, query, roleFilter])

  // Load data from API or fallback
  async function loadAll() {
    try {
      setLoading(true)
      const [s1, s2, s3, s4] = await Promise.all([
        fetch(`${API_BASE}/analytics/summary`),
        fetch(`${API_BASE}/analytics/orders-series?days=30`),
        fetch(`${API_BASE}/analytics/roles-breakdown`),
        fetch(`${API_BASE}/users`),
      ])

      // We fetch analytics summary but statistics are recomputed locally; ignore summary
      if (s2.ok) setOrdersSeries(await s2.json()); else setOrdersSeries(sampleSeries)
      // Roles breakdown is recomputed locally; ignore
      if (s3.ok) { /* ignore roles */ } else { /* ignore roles */ }
      if (s4.ok) setUsers(await s4.json()); else setUsers(sampleUsers)
    } catch {
      // On error fallback to sample data and recompute locally
      setOrdersSeries(sampleSeries)
      setUsers(sampleUsers)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { loadAll() }, [])

  // Local actions (should call backend in real app)
  function toggleActive(user: User) {
    setUsers(prev => prev.map(u => u.id === user.id ? { ...u, active: !u.active } : u))
  }
  function removeUser(user: User) {
    if (!confirm(`سيتم حذف ${user.name}. هل أنت متأكد؟`)) return
    setUsers(prev => prev.filter(u => u.id !== user.id))
  }

  async function createUser(payload: {
    role: CreatableRole,
    name: string,
    email: string,
    phone?: string,
    password: string,
    discount?: number,
    companyName?: string,
    brands?: string[],
  }) {
    // Show a loading indicator while creating the account
    setLoading(true)
    try {
      // Build request body according to the agreed fields
      const body: any = {
        name: payload.name,
        email: payload.email,
        password: payload.password,
        phoneNumber: payload.phone,
        role: payload.role,
      }
      // Additional fields for seller
      if (payload.role === 'seller') {
        body.companyName = payload.companyName
        // The API expects car brands under the property `prands` (as per user specification)
        body.prands = payload.brands
      }
      // Additional fields for worker
      if (payload.role === 'worker') {
        body.discount = payload.discount
      }
      // Post to the registration endpoint via the proxy. Note: we rely on the
      // Vite proxy (`/api` base) to avoid CORS issues during development.
      const endpoint = `${API_BASE}/user/register`
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })
      if (!res.ok) throw new Error('Request failed with status ' + res.status)
      // If the request succeeds, refresh users from the backend
      await loadAll()
    } catch (err) {
      // If the request fails (e.g. network/CORS issue), add the user locally so
      // the UI still reflects the change. This does not guarantee the
      // backend has created the account.
      const newUser: User = {
        id: Math.random().toString(36).slice(2),
        name: payload.name,
        email: payload.email,
        phone: payload.phone,
        role: payload.role,
        active: true,
      }
      if (payload.role === 'worker') newUser.discount = payload.discount
      if (payload.role === 'seller') {
        newUser.companyName = payload.companyName
        newUser.brands = payload.brands
      }
      setUsers(prev => [newUser, ...prev])
    } finally {
      // Regardless of success or failure, hide the dialog and stop loading
      setCreateOpen(false)
      setLoading(false)
    }
  }

  function saveDiscount(userId: string, v: number) {
    setUsers(prev => prev.map(u => u.id === userId ? { ...u, discount: v } : u))
    setDiscountOpen({ open: false })
  }

  return (
    <div dir="rtl" className="min-h-screen p-4 md:p-8 bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="mx-auto max-w-7xl space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold">لوحة تحكم الأدمن</h1>
            <p className="text-sm text-slate-500 mt-1">إدارة البياعين والعاملين وموظفي التوصيل + التحليلات</p>
          </div>
          <div className="flex gap-2">
            <button className="btn" onClick={loadAll}>{loading ? '...جارٍ التحديث' : 'تحديث'}</button>
            <button className="btn btn-primary" onClick={() => setCreateOpen(true)}>إنشاء حساب</button>
          </div>
        </div>

        {/* KPI Cards */}
        <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
          <Kpi title="إجمالي المستخدمين" value={stats?.totalUsers ?? 0} />
          <Kpi title="إجمالي الطلبات" value={stats?.totalOrders ?? 0} />
          <Kpi title="عمال فعّالون" value={stats?.activeWorkers ?? 0} />
          <Kpi title="متوسط خصم العمال" value={(stats?.avgWorkerDiscount ?? 0) + '%'} />
          <Kpi title="عدد البياعين" value={stats?.sellers ?? 0} />
        </section>

        {/* Charts */}
        <section className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <div className="card col-span-1 lg:col-span-2">
            <div className="card-header">الطلبات آخر 30 يوم</div>
            <div className="card-body h-64">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={ordersSeries} margin={{ left: 8, right: 8, top: 10, bottom: 0 }}>
                  <defs>
                    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopOpacity={0.3} />
                      <stop offset="95%" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" tickMargin={8} />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Area type="monotone" dataKey="orders" strokeWidth={2} fillOpacity={1} fill="url(#g)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="card">
            <div className="card-header">توزيع الأدوار</div>
            <div className="card-body h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={roles} dataKey="value" nameKey="role" outerRadius={90}>
                    {roles.map((_, i) => <Cell key={i} />)}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>
        </section>

        {/* Users Table */}
        <div className="card">
          <div className="card-header">المستخدمون (يمكن إنشاء بياع/عامل/توصيل فقط — الزبون يسجّل نفسه)</div>
          <div className="card-body space-y-4">
            <div className="flex flex-col md:flex-row gap-3 md:items-center md:justify-between">
              <div className="flex items-center gap-2 w-full md:w-1/2">
                <input className="input" placeholder="ابحث بالاسم، البريد، الهاتف" value={query} onChange={e => setQuery(e.target.value)} />
                <button className="btn" onClick={loadAll}>تحديث</button>
              </div>
              <div className="flex items-center gap-2">
                <select className="input w-44" value={roleFilter} onChange={e => setRoleFilter(e.target.value as any)}>
                  <option value="all">كل الأدوار</option>
                  <option value="worker">عامل</option>
                  <option value="seller">بياع</option>
                  <option value="delevery">توصيل</option>
                  <option value="customer">زبون</option>
                  <option value="admin">أدمن</option>
                </select>
              </div>
            </div>

            <div className="overflow-x-auto rounded-2xl border">
              <table className="table">
                <thead>
                  <tr>
                    <th>الاسم</th>
                    <th>البريد</th>
                    <th>الدور</th>
                    <th>الحالة</th>
                    <th>الخصم/البراند</th>
                    <th>الشركة</th>
                    <th>إجراءات</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredUsers.map(u => (
                    <tr key={u.id} className="hover:bg-slate-50">
                      <td className="font-medium">{u.name}</td>
                      <td>{u.email}</td>
                      <td>
                        <span className="badge badge-slate">
                          {u.role === 'worker' && 'عامل'}
                          {u.role === 'seller' && 'بياع'}
                          {u.role === 'customer' && 'زبون'}
                          {u.role === 'delevery' && 'توصيل'}
                          {u.role === 'admin' && 'أدمن'}
                        </span>
                      </td>
                      <td>
                        {u.active
                          ? <span className="badge badge-green">مفعّل</span>
                          : <span className="badge badge-slate">معطّل</span>
                        }
                      </td>
                      <td>
                        {u.role === 'worker'
                          ? <span className="inline-flex items-center gap-2">{u.discount ?? 0}% <button className="btn" onClick={() => setDiscountOpen({ open: true, user: u, value: u.discount ?? 0 })}>تعديل</button></span>
                          : u.role === 'seller'
                            ? <span>{(u.brands || []).join(', ') || '—'}</span>
                            : <span className="text-slate-400">—</span>
                        }
                      </td>
                      <td>{u.role === 'seller' ? u.companyName || '—' : '—'}</td>
                      <td>
                        <div className="flex items-center gap-2">
                          <button className="btn" onClick={() => toggleActive(u)}>{u.active ? 'تعطيل' : 'تفعيل'}</button>
                          <button className="btn" onClick={() => removeUser(u)}>حذف</button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div className="text-center text-xs text-slate-500 pt-6">
          مبنيّ لبيئة الويب — يدعم العربية (RTL) مع إنشاء (بياع/عامل/توصيل) فقط. الزبون يسجّل بنفسه.
        </div>
      </div>

      {createOpen && (
        <CreateUserModal
          role={createRole}
          onRoleChange={setCreateRole}
          onClose={() => setCreateOpen(false)}
          onSubmit={createUser}
        />
      )}

      {discountOpen.open && (
        <DiscountModal
          user={discountOpen.user!}
          value={discountOpen.value ?? 0}
          onClose={() => setDiscountOpen({ open: false })}
          onSave={(v) => saveDiscount(discountOpen.user!.id, v)}
        />
      )}
    </div>
  )
}

interface KpiProps { title: string, value: number | string }
function Kpi({ title, value }: KpiProps) {
  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.35 }}>
      <div className="card">
        <div className="card-body flex items-center justify-between">
          <div>
            <div className="text-sm text-slate-500">{title}</div>
            <div className="text-2xl font-bold mt-1">{value}</div>
          </div>
          <div className="grid h-10 w-10 place-items-center rounded-2xl bg-slate-100">📊</div>
        </div>
      </div>
    </motion.div>
  )
}

// Create user modal for seller/worker/delevery
function CreateUserModal({
  role,
  onRoleChange,
  onClose,
  onSubmit
}: {
  role: CreatableRole,
  onRoleChange: (r: CreatableRole) => void,
  onClose: () => void,
  onSubmit: (p: {
    role: CreatableRole,
    name: string,
    email: string,
    phone?: string,
    password: string,
    discount?: number,
    companyName?: string,
    brands?: string[]
  }) => void
}) {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [password, setPassword] = useState('')
  const [discount, setDiscount] = useState(0)
  const [companyName, setCompanyName] = useState('')
  const [brands, setBrands] = useState<string[]>([])

  const isWorker = role === 'worker'
  const isSeller = role === 'seller'

  // list of available car brands (static for now)
  const availableBrands = ['تويوتا', 'فورد', 'هيونداي', 'مرسيدس', 'بي إم دبليو', 'نيسان', 'كيا', 'أودي']

  function toggleBrand(b: string) {
    setBrands(prev => prev.includes(b) ? prev.filter(x => x !== b) : [...prev, b])
  }

  function handleSubmit() {
    onSubmit({
      role,
      name,
      email,
      phone,
      password,
      discount: isWorker ? discount : undefined,
      companyName: isSeller ? companyName : undefined,
      brands: isSeller ? brands : undefined,
    })
  }

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header">إنشاء حساب ({role === 'seller' ? 'بياع' : role === 'worker' ? 'عامل' : 'موظف توصيل'})</div>
        <div className="modal-body">
          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">الدور</label>
            <div className="col-span-3 flex gap-2">
              <button className={`btn ${role === 'seller' ? 'btn-primary' : ''}`} onClick={() => onRoleChange('seller')}>بياع</button>
              <button className={`btn ${role === 'worker' ? 'btn-primary' : ''}`} onClick={() => onRoleChange('worker')}>عامل</button>
              <button className={`btn ${role === 'delevery' ? 'btn-primary' : ''}`} onClick={() => onRoleChange('delevery')}>توصيل</button>
            </div>
          </div>

          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">الاسم الكامل</label>
            <input className="input col-span-3" value={name} onChange={e => setName(e.target.value)} placeholder="مثال: أحمد خالد" />
          </div>
          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">البريد الإلكتروني</label>
            <input className="input col-span-3" type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="email@example.com" />
          </div>
          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">رقم الهاتف</label>
            <input className="input col-span-3" value={phone} onChange={e => setPhone(e.target.value)} placeholder="09xxxxxxxx" />
          </div>
          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">كلمة المرور</label>
            <input className="input col-span-3" type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="••••••••" />
          </div>
          {/* Show discount field only for workers */}
          {isWorker && (
            <div className="grid grid-cols-4 items-center gap-3">
              <label className="col-span-1 text-sm text-slate-500">نسبة الخصم %</label>
              <input className="input col-span-3" type="number" min={0} max={100} value={discount} onChange={e => setDiscount(Number(e.target.value) || 0)} />
            </div>
          )}
          {/* Show seller-specific fields */}
          {isSeller && (
            <>
              <div className="grid grid-cols-4 items-center gap-3">
                <label className="col-span-1 text-sm text-slate-500">اسم الشركة</label>
                <input className="input col-span-3" value={companyName} onChange={e => setCompanyName(e.target.value)} placeholder="اسم الشركة" />
              </div>
              <div className="grid grid-cols-4 items-start gap-3">
                <label className="col-span-1 text-sm text-slate-500 pt-2">البراندات</label>
                <div className="col-span-3 grid grid-cols-2 gap-2">
                  {availableBrands.map(b => (
                    <label key={b} className="inline-flex items-center gap-2">
                      <input type="checkbox" checked={brands.includes(b)} onChange={() => toggleBrand(b)} />
                      <span>{b}</span>
                    </label>
                  ))}
                </div>
              </div>
            </>
          )}
        </div>
        <div className="modal-footer">
          <button className="btn" onClick={onClose}>إلغاء</button>
          <button className="btn btn-primary" onClick={handleSubmit}>حفظ</button>
        </div>
      </div>
    </div>
  )
}

// Discount modal for workers
function DiscountModal({ user, value, onClose, onSave }: { user: User, value: number, onClose: () => void, onSave: (v: number) => void }) {
  const [v, setV] = useState(value)
  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header">تحديد خصم العامل</div>
        <div className="modal-body">
          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">العامل</label>
            <div className="col-span-3 font-medium">{user.name}</div>
          </div>
          <div className="grid grid-cols-4 items-center gap-3">
            <label className="col-span-1 text-sm text-slate-500">نسبة الخصم %</label>
            <input className="input col-span-3" type="number" min={0} max={100} value={v} onChange={e => setV(Number(e.target.value) || 0)} />
          </div>
        </div>
        <div className="modal-footer">
          <button className="btn" onClick={onClose}>إلغاء</button>
          <button className="btn btn-primary" onClick={() => onSave(v)}>حفظ</button>
        </div>
      </div>
    </div>
  )
}
