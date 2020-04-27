<?php namespace EPlacas\Pessoa;

use EPlacas\Model;
use Illuminate\Database\Eloquent\SoftDeletingTrait;

class Naturalidade extends Model
{
    use SoftDeletingTrait;

    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.Naturalidade';

    /**
     * Primary key of table
     * @var string
     */
    protected $primaryKey = 'Id';

    /**
     * Campos mass-assigment
     * @var array
     */
    protected $fillable = array('CidadeId', 'EstadoId');

    protected $guarded = array('description');

    protected $dates = array('deleted_at');

    public static function name()
    {
        return 'Naturalidade';
    }

    /**
     * Regras para validação
     * @var array
     */
    public function storeRules()
    {
        return array(
        'CidadeId' => 'exists:Bludata.Cidade,Id',
        'EstadoId' => 'exists:Bludata.Estado,Id',
        );
    }

    /**
     * Regras para validação de edição
     * @return array
     */
    public function updateRules()
    {
        return $this->storeRules();
    }

    public function getDescriptionAttribute()
    {
        return $this->cidade->description . ', ' . $this->estado->description;
    }

    /**
     * Naturalidade pertence a um registro de Pessoa
     * @return Pessoa
     */
    public function pessoa()
    {
        return $this->belongsTo('EPlacas\Pessoa\Pessoa', 'Id', 'PessoaId');
    }

    /**
     * Naturalidade pertence a um registro de Pessoa
     * @return Pessoa
     */
    public function cidade()
    {
        return $this->hasOne('EPlacas\Localizacao\Cidade', 'Id', 'CidadeId');
    }

    /**
     * Naturalidade pertence a um registro de Pessoa
     * @return Pessoa
     */
    public function estado()
    {
        return $this->hasOne('EPlacas\Localizacao\Estado', 'Id', 'EstadoId');
    }
}
