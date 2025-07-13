import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get the service role client for admin operations
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Verify the user is authenticated and has permission
    const {
      data: { user },
    } = await supabaseClient.auth.getUser()

    if (!user) {
      throw new Error('Not authenticated')
    }

    // Get request body
    const { email, password, userData } = await req.json()

    if (!email || !password) {
      throw new Error('Email and password are required')
    }

    // Create auth user with admin client
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        name: userData.name,
        department: userData.department,
        position: userData.position,
      }
    })

    if (authError) {
      throw authError
    }

    // Insert/update user profile
    const { error: profileError } = await supabaseAdmin
      .from('users')
      .upsert({
        id: authData.user.id,
        email: email,
        name: userData.name,
        division: userData.division,
        department: userData.department,
        position: userData.position,
        status: userData.status,
        phone: userData.phone,
        birthday: userData.birthday || null,
        joindate: userData.joindate || null,
        avatar_url: userData.avatar_url || null,
      })

    if (profileError) {
      // If profile creation fails, try to delete the auth user
      await supabaseAdmin.auth.admin.deleteUser(authData.user.id)
      throw profileError
    }

    return new Response(
      JSON.stringify({
        success: true,
        userId: authData.user.id,
        message: 'Employee created successfully'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
}) 