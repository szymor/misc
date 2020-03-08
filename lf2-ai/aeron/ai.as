int face_distance()
// distance to target, positive when faced towards it
// 80 pixels may be considered as a maximum distance allowing close combat
{
    return ( self.x - target.x ) * ( 2 * ( self.facing ? 1 : 0 ) - 1 );
}

bool dist_between( int min, int max )
// checks whether distance to target is within bounds
{
    return ( ( face_distance() < max ) && ( face_distance() > min ) );
}

bool z_axis_dist( int dist )
{
    return ( abs( self.z - target.z ) <= dist ) ? true : false;
}

bool same_z_axis()
// checks whether our character is on the same z axis as the opponent
{
    return ( abs( self.z - target.z ) <= 8 ) ? true : false;
}

void select_nearest_opponent()
{
    int temp;
    int k = -1;
    int min_dist = 0;
    for( int i = 0; i < 400; ++i )
    {
        temp = loadTarget(i);
        if( ( temp == 0 ) && ( target.team != self.team ) && ( ( abs( self.x - target.x ) < min_dist ) || ( k == -1 ) ) )
        {
            k = i;
            min_dist = abs( self.x - target.x );
        }
    }
    loadTarget(k);
}

void follow_target()
{
    if( ( self.x > 100 ) && ( self.x < stage_bound - 100 ) )
    {
        if( self.x > target.x )
        {
            left();
            if( face_distance() > 400 )
                J();
        }
        if( self.x < target.x )
        {
            right();
            if( face_distance() > 400 )
                J();
        }
        if( self.z + 3 < target.z )
            down();
        if( self.z > target.z + 3 )
            up();
        if( dist_between(-25,25) )
            J(); // we do not want to be too close..
    }
    else
    {
        if( self.x <= 100 )
            right();
        if( self.x >= stage_bound - 100 )
            left();
    }
}

void attack_opponent()
{
    if( target.team != self.team )
    {
        if( dist_between(100,200) && same_z_axis() && ( self.mp > 300 ) && ( target.state != 14 ) )
        {
            if( self.facing )
            {
                DlJ();
            }
            else
            {
                DrJ();
            }
            return;
        }
        if( dist_between(200,500) && same_z_axis() && ( self.mp > 200 ) && ( target.state != 14 ) )
        {
            if( self.facing )
            {
                DlA();
            }
            else
            {
                DrA();
            }
            return;
        }
        if( dist_between(100,200) && same_z_axis() && ( target.state < 3 ) && ( target.state != 14 ) )
        {
            J();
            return;
        }
        if( dist_between(50,100) && same_z_axis() && ( target.state != 14 ) )
        {
            A();
            return;
        }
    }
}

void reset_input()
{
    left(0,0);
    right(0,0);
    up(0,0);
    down(0,0);
    A(0,0);
    D(0,0);
    J(0,0);
}

void id()
{
    reset_input();
    if( !stage_clear )
    {
        select_nearest_opponent();
        attack_opponent();
        follow_target();
    }
    else
    {
        right();
        if( !self.facing )
            J();
    }
}
